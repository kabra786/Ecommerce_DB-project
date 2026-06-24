-- ============================================================
-- STAGE 3: ADVANCED DATABASE PROGRAMMING
-- Oracle PL/SQL | E-Commerce Project
-- ============================================================


-- ============================================================
-- SECTION 1: STORED PROCEDURES
-- ============================================================

-- ------------------------------------------------------------
-- 1.1 place_order
-- Full atomic purchase: validates stock, creates order,
-- inserts items, deducts inventory, logs payment & shipment
-- ------------------------------------------------------------

CREATE OR REPLACE PROCEDURE place_order (
    p_user_id        IN orders.user_id%TYPE,
    p_product_ids    IN SYS.ODCINUMBERLIST,
    p_quantities     IN SYS.ODCINUMBERLIST,
    p_prices         IN SYS.ODCINUMBERLIST,
    p_payment_method IN payments.payment_method%TYPE,
    p_courier        IN shipments.courier_name%TYPE
)
AS
    v_order_id    NUMBER;
    v_total       NUMBER := 0;
    v_stock       NUMBER;
    v_shipment_no VARCHAR2(100);
BEGIN
    -- Validate array lengths match
    IF p_product_ids.COUNT != p_quantities.COUNT
       OR p_product_ids.COUNT != p_prices.COUNT THEN
        RAISE_APPLICATION_ERROR(-20100, 'Mismatched product/quantity/price arrays.');
    END IF;

    -- Validate each product stock before doing anything
    FOR i IN 1 .. p_product_ids.COUNT LOOP
        SELECT stock_quantity
          INTO v_stock
          FROM inventory
         WHERE product_id = p_product_ids(i)
           FOR UPDATE;

        IF v_stock < p_quantities(i) THEN
            RAISE_APPLICATION_ERROR(
                -20101,
                'Insufficient stock for product_id=' || p_product_ids(i)
                || '. Available=' || v_stock
                || ', Requested=' || p_quantities(i)
            );
        END IF;

        v_total := v_total + (p_quantities(i) * p_prices(i));
    END LOOP;

    -- Create order header
    v_order_id := seq_orders.NEXTVAL;

    INSERT INTO orders (
        order_id,
        user_id,
        order_date,
        total_amount,
        status
    )
    VALUES (
        v_order_id,
        p_user_id,
        SYSDATE,
        v_total,
        'CONFIRMED'
    );

    -- Insert order items and deduct inventory
    FOR i IN 1 .. p_product_ids.COUNT LOOP

        INSERT INTO order_items (
            order_item_id,
            order_id,
            product_id,
            quantity,
            price
        )
        VALUES (
            seq_order_items.NEXTVAL,
            v_order_id,
            p_product_ids(i),
            p_quantities(i),
            p_prices(i)
        );

        UPDATE inventory
           SET stock_quantity = stock_quantity - p_quantities(i),
               last_updated   = SYSDATE
         WHERE product_id = p_product_ids(i);

    END LOOP;

    -- Record payment
    INSERT INTO payments (
        payment_id,
        order_id,
        payment_method,
        payment_status,
        payment_date,
        amount
    )
    VALUES (
        seq_payments.NEXTVAL,
        v_order_id,
        p_payment_method,
        'PENDING',
        SYSDATE,
        v_total
    );

    -- Create shipment
    v_shipment_no :=
        'TRK-' || TO_CHAR(SYSDATE,'YYYYMMDD')
        || '-' || v_order_id;

    INSERT INTO shipments (
        shipment_id,
        order_id,
        tracking_number,
        courier_name,
        shipment_status,
        shipped_date,
        delivery_date
    )
    VALUES (
        seq_shipments.NEXTVAL,
        v_order_id,
        v_shipment_no,
        p_courier,
        'PENDING',
        NULL,
        NULL
    );

    -- Initial status history
    INSERT INTO order_status_history (
        status_id,
        order_id,
        status,
        updated_at
    )
    VALUES (
        seq_status_history.NEXTVAL,
        v_order_id,
        'CONFIRMED',
        SYSDATE
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(
        'SUCCESS: Order #' || v_order_id ||
        ' placed. Total=' || v_total ||
        ' | Tracking=' || v_shipment_no
    );

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE(
            'FAILED place_order: ' || SQLERRM
        );
        RAISE;

END place_order;
/

-- ------------------------------------------------------------
-- 1.2 cancel_order
-- Cancels an order, restores inventory, voids payment
-- ------------------------------------------------------------

CREATE OR REPLACE PROCEDURE cancel_order (
    p_order_id IN orders.order_id%TYPE,
    p_reason   IN VARCHAR2 DEFAULT 'Customer request'
)
AS
    v_status orders.status%TYPE;
    v_exists NUMBER;
BEGIN

    SELECT COUNT(*)
    INTO v_exists
    FROM orders
    WHERE order_id = p_order_id;

    IF v_exists = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20110,
            'Order #' || p_order_id || ' not found.'
        );
    END IF;

    SELECT status
    INTO v_status
    FROM orders
    WHERE order_id = p_order_id
    FOR UPDATE;

    IF v_status IN (
        'DELIVERED',
        'CANCELLED',
        'RETURNED',
        'REFUNDED'
    ) THEN
        RAISE_APPLICATION_ERROR(
            -20111,
            'Order #' || p_order_id ||
            ' cannot be cancelled. Status=' || v_status
        );
    END IF;
        -- Restore inventory for each item
    FOR rec IN (
        SELECT product_id, quantity
        FROM order_items
        WHERE order_id = p_order_id
    ) LOOP

        UPDATE inventory
           SET stock_quantity = stock_quantity + rec.quantity,
               last_updated   = SYSDATE
         WHERE product_id = rec.product_id;

    END LOOP;

    -- Update order status
    UPDATE orders
       SET status = 'CANCELLED'
     WHERE order_id = p_order_id;

    -- Void payment
    UPDATE payments
       SET payment_status = 'CANCELLED'
     WHERE order_id = p_order_id
       AND payment_status = 'PENDING';

    -- Update shipment
    UPDATE shipments
       SET shipment_status = 'RETURNED'
     WHERE order_id = p_order_id
       AND shipment_status = 'PENDING';

    -- Log status change
    INSERT INTO order_status_history (
        status_id,
        order_id,
        status,
        updated_at
    )
    VALUES (
        seq_status_history.NEXTVAL,
        p_order_id,
        'CANCELLED',
        SYSDATE
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(
        'Order #' || p_order_id ||
        ' cancelled. Reason: ' || p_reason
    );

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE(
            'FAILED cancel_order: ' || SQLERRM
        );
        RAISE;

END cancel_order;
/

-- ------------------------------------------------------------
-- 1.3 restock_product
-- Adds stock to a product's inventory record
-- ------------------------------------------------------------

CREATE OR REPLACE PROCEDURE restock_product (
    p_product_id IN inventory.product_id%TYPE,
    p_quantity   IN NUMBER,
    p_notes      IN VARCHAR2 DEFAULT NULL
)
AS
    v_exists    NUMBER;
    v_old_stock NUMBER;
    v_new_stock NUMBER;
BEGIN

    IF p_quantity <= 0 THEN
        RAISE_APPLICATION_ERROR(
            -20120,
            'Restock quantity must be positive.'
        );
    END IF;

    SELECT COUNT(*)
    INTO v_exists
    FROM products
    WHERE product_id = p_product_id;

    IF v_exists = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20121,
            'Product_id=' || p_product_id || ' not found.'
        );
    END IF;

    SELECT stock_quantity
    INTO v_old_stock
    FROM inventory
    WHERE product_id = p_product_id
    FOR UPDATE;

    UPDATE inventory
       SET stock_quantity = stock_quantity + p_quantity,
           last_updated = SYSDATE
     WHERE product_id = p_product_id;

    v_new_stock := v_old_stock + p_quantity;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(
        'Restocked product_id=' || p_product_id ||
        ' | Before=' || v_old_stock ||
        ' | Added=' || p_quantity ||
        ' | After=' || v_new_stock ||
        CASE
            WHEN p_notes IS NOT NULL
            THEN ' | Notes: ' || p_notes
            ELSE ''
        END
    );

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE(
            'No inventory record for product_id=' || p_product_id
        );
        RAISE;

    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE(
            'FAILED restock_product: ' || SQLERRM
        );
        RAISE;

END restock_product;
/

-- ------------------------------------------------------------
-- 1.4 update_order_status
-- Transitions order status and logs the change
-- ------------------------------------------------------------

CREATE OR REPLACE PROCEDURE update_order_status (
    p_order_id   IN orders.order_id%TYPE,
    p_new_status IN orders.status%TYPE
)
AS
    v_old_status orders.status%TYPE;
    v_allowed VARCHAR2(200);

    FUNCTION allowed_next(
        p_status VARCHAR2
    ) RETURN VARCHAR2 IS
    BEGIN

        CASE p_status
            WHEN 'PENDING' THEN
                RETURN 'CONFIRMED,CANCELLED';

            WHEN 'CONFIRMED' THEN
                RETURN 'PROCESSING,CANCELLED';

            WHEN 'PROCESSING' THEN
                RETURN 'SHIPPED,CANCELLED';

            WHEN 'SHIPPED' THEN
                RETURN 'DELIVERED,RETURNED';

            WHEN 'DELIVERED' THEN
                RETURN 'RETURNED';

            ELSE
                RETURN '';
        END CASE;

    END;

BEGIN
    SELECT status
    INTO v_old_status
    FROM orders
    WHERE order_id = p_order_id
    FOR UPDATE;

    v_allowed := allowed_next(v_old_status);

    IF INSTR(',' || v_allowed || ',', ',' || p_new_status || ',') = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20130,
            'Invalid transition: ' || v_old_status ||
            ' → ' || p_new_status ||
            '. Allowed: ' || v_allowed
        );
    END IF;

    UPDATE orders
       SET status = p_new_status
     WHERE order_id = p_order_id;

    -- Update shipment status
    IF p_new_status = 'SHIPPED' THEN

        UPDATE shipments
           SET shipment_status = 'IN_TRANSIT',
               shipped_date = SYSDATE
         WHERE order_id = p_order_id;

    ELSIF p_new_status = 'DELIVERED' THEN

        UPDATE shipments
           SET shipment_status = 'DELIVERED',
               delivery_date = SYSDATE
         WHERE order_id = p_order_id;

        UPDATE payments
           SET payment_status = 'COMPLETED'
         WHERE order_id = p_order_id
           AND payment_status = 'PENDING';

    ELSIF p_new_status = 'RETURNED' THEN

        UPDATE shipments
           SET shipment_status = 'RETURNED'
         WHERE order_id = p_order_id;

    END IF;

    INSERT INTO order_status_history (
        status_id,
        order_id,
        status,
        updated_at
    )
    VALUES (
        seq_status_history.NEXTVAL,
        p_order_id,
        p_new_status,
        SYSDATE
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(
        'Order #' || p_order_id ||
        ': ' || v_old_status ||
        ' → ' || p_new_status
    );

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE(
            'Order #' || p_order_id || ' not found.'
        );
        RAISE;

    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE(
            'FAILED update_order_status: ' || SQLERRM
        );
        RAISE;

END update_order_status;
/

-- ------------------------------------------------------------
-- 1.5 add_review
-- Submits a product review; prevents duplicate user+product combos
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE add_review (
    p_user_id    IN reviews.user_id%TYPE,
    p_product_id IN reviews.product_id%TYPE,
    p_rating     IN reviews.rating%TYPE,
    p_comment    IN reviews.review_comment%TYPE
)
AS
    v_exists     NUMBER;
    v_purchased  NUMBER;
BEGIN
    -- rating validation
    IF p_rating < 1 OR p_rating > 5 THEN
        RAISE_APPLICATION_ERROR(-20140, 'Rating must be between 1 and 5.');
    END IF;

    -- check duplicate review
    SELECT COUNT(*)
      INTO v_exists
      FROM reviews
     WHERE user_id = p_user_id
       AND product_id = p_product_id;

    IF v_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20141, 'User has already reviewed this product.');
    END IF;

    -- check if product was delivered in an order
    SELECT COUNT(*)
      INTO v_purchased
      FROM orders o
      JOIN order_items oi ON o.order_id = oi.order_id
     WHERE o.user_id = p_user_id
       AND oi.product_id = p_product_id
       AND o.status = 'DELIVERED';

    IF v_purchased = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20142,
            'User must have a delivered order for this product to review it.'
        );
    END IF;

    -- insert review
    INSERT INTO reviews (
        review_id, user_id, product_id,
        rating, review_comment, review_date
    )
    VALUES (
        seq_reviews.NEXTVAL,
        p_user_id,
        p_product_id,
        p_rating,
        p_comment,
        SYSDATE
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(
        'Review added: user=' || p_user_id ||
        ', product=' || p_product_id ||
        ', rating=' || p_rating
    );

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('FAILED add_review: ' || SQLERRM);
        RAISE;
END add_review;
/

-- ------------------------------------------------------------
-- 1.6 clear_cart
-- Removes all or a specific item from a user's cart
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE clear_cart (
    p_user_id    IN cart_items.user_id%TYPE,
    p_product_id IN cart_items.product_id%TYPE DEFAULT NULL
)
AS
    v_deleted NUMBER;
BEGIN
    IF p_product_id IS NULL THEN
        DELETE FROM cart_items WHERE user_id = p_user_id;
    ELSE
        DELETE FROM cart_items
         WHERE user_id = p_user_id
           AND product_id = p_product_id;
    END IF;

    v_deleted := SQL%ROWCOUNT;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(
        v_deleted || ' cart item(s) removed for user_id=' || p_user_id
    );

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('FAILED clear_cart: ' || SQLERRM);
        RAISE;
END clear_cart;
/

-- ------------------------------------------------------------
-- 1.7 apply_discount
-- Applies a percentage discount to a pending order total
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE apply_discount (
    p_order_id        IN orders.order_id%TYPE,
    p_discount_pct    IN NUMBER
)
AS
    v_status      orders.status%TYPE;
    v_old_total   orders.total_amount%TYPE;
    v_discount    NUMBER;
    v_new_total   NUMBER;
BEGIN
    IF p_discount_pct <= 0 OR p_discount_pct > 100 THEN
        RAISE_APPLICATION_ERROR(-20150, 'Discount must be between 1 and 100 percent.');
    END IF;

    SELECT status, total_amount
      INTO v_status, v_old_total
      FROM orders
     WHERE order_id = p_order_id
       FOR UPDATE;

    IF v_status NOT IN ('PENDING', 'CONFIRMED') THEN
        RAISE_APPLICATION_ERROR(-20151, 'Discount can only be applied to PENDING or CONFIRMED orders.');
    END IF;

    v_discount  := ROUND(v_old_total * p_discount_pct / 100, 2);
    v_new_total := v_old_total - v_discount;

    UPDATE orders
       SET total_amount = v_new_total
     WHERE order_id = p_order_id;

    UPDATE payments
       SET amount = v_new_total
     WHERE order_id = p_order_id
       AND payment_status = 'PENDING';

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(
        'Discount applied to order #' || p_order_id ||
        ' | ' || p_discount_pct || '% off' ||
        ' | Old=' || v_old_total ||
        ' | Saved=' || v_discount ||
        ' | New=' || v_new_total
    );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Order #' || p_order_id || ' not found.');
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('FAILED apply_discount: ' || SQLERRM);
        RAISE;
END apply_discount;
/

-- ------------------------------------------------------------
-- 1.8 create_shipment
-- Manually creates or updates a shipment record for an order
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE create_shipment (
    p_order_id        IN shipments.order_id%TYPE,
    p_courier         IN shipments.courier_name%TYPE,
    p_tracking_no     IN shipments.tracking_number%TYPE DEFAULT NULL,
    p_days_to_deliver IN NUMBER DEFAULT 5
)
AS
    v_exists       NUMBER;
    v_order_status orders.status%TYPE;
    v_tracking     VARCHAR2(100);
BEGIN
    SELECT COUNT(*) INTO v_exists
      FROM shipments
     WHERE order_id = p_order_id;

    SELECT status INTO v_order_status
      FROM orders
     WHERE order_id = p_order_id;

    IF v_order_status NOT IN ('CONFIRMED', 'PROCESSING', 'SHIPPED') THEN
        RAISE_APPLICATION_ERROR(
            -20160,
            'Cannot create shipment for order in status: ' || v_order_status
        );
    END IF;

    v_tracking := NVL(
        p_tracking_no,
        'TRK-' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' || p_order_id
    );

    IF v_exists = 0 THEN
        INSERT INTO shipments (
            shipment_id, order_id, tracking_number,
            courier_name, shipment_status,
            shipped_date, delivery_date
        )
        VALUES (
            seq_shipments.NEXTVAL,
            p_order_id,
            v_tracking,
            p_courier,
            'DISPATCHED',
            SYSDATE,
            SYSDATE + p_days_to_deliver
        );
    ELSE
        UPDATE shipments
           SET tracking_number = v_tracking,
               courier_name    = p_courier,
               shipment_status = 'DISPATCHED',
               shipped_date    = SYSDATE,
               delivery_date   = SYSDATE + p_days_to_deliver
         WHERE order_id = p_order_id;
    END IF;

    UPDATE orders
       SET status = 'SHIPPED'
     WHERE order_id = p_order_id;

    INSERT INTO order_status_history (
        status_id, order_id, status, updated_at
    )
    VALUES (
        seq_status_history.NEXTVAL,
        p_order_id,
        'SHIPPED',
        SYSDATE
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(
        'Shipment created | order=' || p_order_id ||
        ' | tracking=' || v_tracking ||
        ' | courier=' || p_courier
    );

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('FAILED create_shipment: ' || SQLERRM);
        RAISE;
END create_shipment;
/

-- ============================================================
-- SECTION 2: FUNCTIONS
-- ============================================================

-- ------------------------------------------------------------
-- 2.1 fn_total_spent_by_user
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_total_spent_by_user (
    p_user_id IN users.user_id%TYPE
) RETURN NUMBER
AS
    v_total NUMBER := 0;
BEGIN
    SELECT NVL(SUM(total_amount), 0)
      INTO v_total
      FROM orders
     WHERE user_id = p_user_id
       AND status NOT IN ('CANCELLED', 'RETURNED', 'REFUNDED');

    RETURN ROUND(v_total, 2);

EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END fn_total_spent_by_user;
/

-- ------------------------------------------------------------
-- 2.2 fn_product_average_rating
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_product_average_rating (
    p_product_id IN products.product_id%TYPE
) RETURN NUMBER
AS
    v_avg NUMBER := 0;
BEGIN
    SELECT NVL(ROUND(AVG(rating), 2), 0)
      INTO v_avg
      FROM reviews
     WHERE product_id = p_product_id;

    RETURN v_avg;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END fn_product_average_rating;
/

-- ------------------------------------------------------------
-- 2.3 fn_available_stock
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_available_stock (
    p_product_id IN inventory.product_id%TYPE
) RETURN NUMBER
AS
    v_qty NUMBER := 0;
BEGIN
    SELECT NVL(stock_quantity, 0)
      INTO v_qty
      FROM inventory
     WHERE product_id = p_product_id;

    RETURN v_qty;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -1;
    WHEN OTHERS THEN
        RETURN -1;
END fn_available_stock;
/

-- ------------------------------------------------------------
-- 2.4 fn_total_orders_by_user
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_total_orders_by_user (
    p_user_id IN users.user_id%TYPE
) RETURN NUMBER
AS
    v_count NUMBER := 0;
BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM orders
     WHERE user_id = p_user_id
       AND status NOT IN ('CANCELLED');

    RETURN v_count;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END fn_total_orders_by_user;
/

-- ------------------------------------------------------------
-- 2.5 fn_order_total
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_order_total (
    p_order_id IN orders.order_id%TYPE
) RETURN NUMBER
AS
    v_total NUMBER := 0;
BEGIN
    SELECT NVL(SUM(quantity * price), 0)
      INTO v_total
      FROM order_items
     WHERE order_id = p_order_id;

    RETURN ROUND(v_total, 2);

EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END fn_order_total;
/

-- ------------------------------------------------------------
-- 2.6 fn_customer_tier
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_customer_tier (
    p_user_id IN users.user_id%TYPE
) RETURN VARCHAR2
AS
    v_spend NUMBER := 0;
BEGIN
    v_spend := fn_total_spent_by_user(p_user_id);

    RETURN CASE
        WHEN v_spend >= 5000 THEN 'PLATINUM'
        WHEN v_spend >= 2000 THEN 'GOLD'
        WHEN v_spend >= 500  THEN 'SILVER'
        WHEN v_spend > 0     THEN 'BRONZE'
        ELSE 'NEW'
    END;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'UNKNOWN';
END fn_customer_tier;
/

-- ============================================================
-- SECTION 3: TRIGGERS (FIXED VERSION)
-- ============================================================

-- ------------------------------------------------------------
-- 3.1 Prevent negative stock before updating inventory
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_prevent_negative_stock
BEFORE UPDATE OF stock_quantity ON inventory
FOR EACH ROW
BEGIN
    IF :NEW.stock_quantity < 0 THEN
        RAISE_APPLICATION_ERROR(
            -20200,
            'Stock cannot go negative. Product_id=' || :NEW.product_id ||
            '. Current=' || :OLD.stock_quantity
        );
    END IF;
END;
/

-- ------------------------------------------------------------
-- 3.2 Auto-deduct inventory after order item insert
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_deduct_inventory_on_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE inventory
       SET stock_quantity = stock_quantity - :NEW.quantity,
           last_updated   = SYSDATE
     WHERE product_id = :NEW.product_id;
END;
/

-- ------------------------------------------------------------
-- 3.3 Auto-restore inventory after order item delete
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_restore_inventory_on_delete
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
    UPDATE inventory
       SET stock_quantity = stock_quantity + :OLD.quantity,
           last_updated   = SYSDATE
     WHERE product_id = :OLD.product_id;
END;
/

-- ------------------------------------------------------------
-- 3.4 Recalculate order total (FIXED - mutating-safe logic kept)
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_update_order_total
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders o
       SET total_amount = (
            SELECT NVL(SUM(quantity * price), 0)
              FROM order_items oi
             WHERE oi.order_id = o.order_id
       )
     WHERE o.order_id = NVL(:NEW.order_id, :OLD.order_id);
END;
/

-- ------------------------------------------------------------
-- 3.5 Auto-create status history on order insert
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_order_status_history_on_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO order_status_history (
        status_id, order_id, status, updated_at
    )
    VALUES (
        seq_status_history.NEXTVAL,
        :NEW.order_id,
        :NEW.status,
        SYSDATE
    );
END;
/

-- ------------------------------------------------------------
-- 3.6 Log order status changes
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_order_status_history_on_update
AFTER UPDATE OF status ON orders
FOR EACH ROW
BEGIN
    IF :OLD.status <> :NEW.status THEN
        INSERT INTO order_status_history (
            status_id, order_id, status, updated_at
        )
        VALUES (
            seq_status_history.NEXTVAL,
            :NEW.order_id,
            :NEW.status,
            SYSDATE
        );
    END IF;
END;
/

-- ------------------------------------------------------------
-- 3.7 Auto-update inventory timestamp
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_inventory_last_updated
BEFORE UPDATE ON inventory
FOR EACH ROW
BEGIN
    :NEW.last_updated := SYSDATE;
END;
/

-- ------------------------------------------------------------
-- 3.8 Validate review rating (1 to 5)
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_validate_review_rating
BEFORE INSERT OR UPDATE ON reviews
FOR EACH ROW
BEGIN
    IF :NEW.rating < 1 OR :NEW.rating > 5 THEN
        RAISE_APPLICATION_ERROR(
            -20220,
            'Rating must be between 1 and 5. Got: ' || :NEW.rating
        );
    END IF;
END;
/

-- ------------------------------------------------------------
-- 3.9 Prevent modification of final orders
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_lock_finalized_orders
BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
    IF :OLD.status IN ('DELIVERED', 'CANCELLED', 'REFUNDED') THEN
        RAISE_APPLICATION_ERROR(
            -20230,
            'Order #' || :OLD.order_id ||
            ' is finalized (' || :OLD.status || ') and cannot be modified.'
        );
    END IF;
END;
/

-- ============================================================
-- SECTION 4: CURSORS (FIXED VERSION)
-- ============================================================

-- ------------------------------------------------------------
-- 4.1 Low Stock Report
-- ------------------------------------------------------------
DECLARE
    CURSOR cur_low_stock (p_threshold NUMBER DEFAULT 20) IS
        SELECT p.product_id, p.name AS product_name, c.category_name,
               i.stock_quantity, p.price
          FROM inventory i
          JOIN products   p ON i.product_id  = p.product_id
          JOIN categories c ON p.category_id = c.category_id
         WHERE i.stock_quantity <= p_threshold
         ORDER BY i.stock_quantity ASC;

    v_rec cur_low_stock%ROWTYPE;
    v_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('LOW STOCK REPORT (<=20)');

    OPEN cur_low_stock(20);
    LOOP
        FETCH cur_low_stock INTO v_rec;
        EXIT WHEN cur_low_stock%NOTFOUND;

        v_count := v_count + 1;

        DBMS_OUTPUT.PUT_LINE(
            'Product #' || v_rec.product_id ||
            ' | ' || v_rec.product_name ||
            ' | Stock: ' || v_rec.stock_quantity
        );
    END LOOP;
    CLOSE cur_low_stock;

    DBMS_OUTPUT.PUT_LINE('Total flagged: ' || v_count);
END;
/

-- ------------------------------------------------------------
-- 4.2 Top Customers Report (FIXED NULL SAFE)
-- ------------------------------------------------------------
DECLARE
    CURSOR cur_top_customers IS
        SELECT u.user_id, u.name, u.email,
               COUNT(DISTINCT o.order_id) AS order_count,
               NVL(SUM(o.total_amount),0) AS total_spent
          FROM users u
          JOIN orders o ON u.user_id = o.user_id
         WHERE o.status NOT IN ('CANCELLED','RETURNED','REFUNDED')
         GROUP BY u.user_id, u.name, u.email
         ORDER BY NVL(SUM(o.total_amount),0) DESC;

    v_rank NUMBER := 0;
BEGIN
    FOR rec IN cur_top_customers LOOP
        v_rank := v_rank + 1;

        EXIT WHEN v_rank > 10;

        DBMS_OUTPUT.PUT_LINE(
            '#' || v_rank ||
            ' | User #' || rec.user_id ||
            ' | ' || rec.name ||
            ' | Orders: ' || rec.order_count ||
            ' | Spent: ' || rec.total_spent ||
            ' | Tier: ' || fn_customer_tier(rec.user_id)
        );
    END LOOP;
END;
/

-- ------------------------------------------------------------
-- 4.3 Monthly Sales Summary (FIXED NULL SAFE)
-- ------------------------------------------------------------
DECLARE
    CURSOR cur_monthly_sales IS
        SELECT TO_CHAR(o.order_date,'YYYY-MM') AS month_label,
               COUNT(DISTINCT o.order_id) AS orders,
               COUNT(DISTINCT o.user_id) AS customers,
               NVL(SUM(o.total_amount),0) AS revenue,
               NVL(ROUND(AVG(o.total_amount),2),0) AS avg_order_val
          FROM orders o
         WHERE o.status NOT IN ('CANCELLED','RETURNED','REFUNDED')
           AND o.order_date >= ADD_MONTHS(SYSDATE,-6)
         GROUP BY TO_CHAR(o.order_date,'YYYY-MM')
         ORDER BY month_label DESC;

BEGIN
    FOR rec IN cur_monthly_sales LOOP
        DBMS_OUTPUT.PUT_LINE(
            rec.month_label ||
            ' | Orders: ' || rec.orders ||
            ' | Customers: ' || rec.customers ||
            ' | Revenue: ' || rec.revenue ||
            ' | Avg: ' || rec.avg_order_val
        );
    END LOOP;
END;
/

-- ------------------------------------------------------------
-- 4.4 Pending Shipments Report
-- ------------------------------------------------------------
DECLARE
    CURSOR cur_pending_shipments IS
        SELECT s.shipment_id, s.tracking_number, s.courier_name,
               s.shipment_status, o.order_id, u.name AS customer,
               o.order_date,
               ROUND(SYSDATE - o.order_date, 0) AS days_pending
          FROM shipments s
          JOIN orders o ON s.order_id = o.order_id
          JOIN users  u ON o.user_id  = u.user_id
         WHERE s.shipment_status IN ('PENDING','DISPATCHED','IN_TRANSIT')
         ORDER BY o.order_date ASC;

    v_total NUMBER := 0;
BEGIN
    FOR rec IN cur_pending_shipments LOOP
        v_total := v_total + 1;

        DBMS_OUTPUT.PUT_LINE(
            'Shipment #' || rec.shipment_id ||
            ' | Order #' || rec.order_id ||
            ' | Customer: ' || rec.customer ||
            ' | Status: ' || rec.shipment_status ||
            ' | Days: ' || rec.days_pending
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Total pending: ' || v_total);
END;
/

-- ------------------------------------------------------------
-- 4.5 Products Never Ordered
-- ------------------------------------------------------------
DECLARE
    CURSOR cur_never_ordered IS
        SELECT p.product_id, p.name, c.category_name, p.price, i.stock_quantity
          FROM products p
          JOIN categories c ON p.category_id = c.category_id
          JOIN inventory  i ON p.product_id  = i.product_id
         WHERE NOT EXISTS (
               SELECT 1 FROM order_items oi
               WHERE oi.product_id = p.product_id
         );

BEGIN
    FOR rec IN cur_never_ordered LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Product #' || rec.product_id ||
            ' | ' || rec.name ||
            ' | Stock: ' || rec.stock_quantity
        );
    END LOOP;
END;
/

-- ------------------------------------------------------------
-- 4.6 Inactive Users
-- ------------------------------------------------------------
DECLARE
    CURSOR cur_inactive_users IS
        SELECT u.user_id, u.name, u.email, u.created_at,
               ROUND(SYSDATE - u.created_at, 0) AS days_since_joined
          FROM users u
         WHERE NOT EXISTS (
               SELECT 1 FROM orders o WHERE o.user_id = u.user_id
         );

    v_count NUMBER := 0;
BEGIN
    FOR rec IN cur_inactive_users LOOP
        v_count := v_count + 1;

        DBMS_OUTPUT.PUT_LINE(
            'User #' || rec.user_id ||
            ' | ' || rec.name ||
            ' | Days inactive: ' || rec.days_since_joined
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Total inactive users: ' || v_count);
END;
/

-- ============================================================
-- SECTION 5: PACKAGE (FIXED VERSION)
-- ============================================================

CREATE OR REPLACE PACKAGE ecommerce_pkg AS

    FUNCTION calculate_discount (
        p_user_id      IN users.user_id%TYPE,
        p_order_amount IN NUMBER
    ) RETURN NUMBER;

    FUNCTION get_customer_level (
        p_user_id IN users.user_id%TYPE
    ) RETURN VARCHAR2;

    PROCEDURE order_summary (
        p_order_id IN orders.order_id%TYPE
    );

    PROCEDURE inventory_alert (
        p_category_id IN categories.category_id%TYPE,
        p_threshold   IN NUMBER DEFAULT 15
    );

    PROCEDURE bulk_restock_category (
        p_category_id   IN categories.category_id%TYPE,
        p_restock_qty   IN NUMBER DEFAULT 100,
        p_threshold     IN NUMBER DEFAULT 20
    );

    FUNCTION get_product_info (
        p_product_id IN products.product_id%TYPE
    ) RETURN VARCHAR2;

    PROCEDURE top_products_by_revenue (
        p_top_n IN NUMBER DEFAULT 5
    );

    PROCEDURE user_spending_report (
        p_user_id IN users.user_id%TYPE
    );

END ecommerce_pkg;
/

-- ============================================================

CREATE OR REPLACE PACKAGE BODY ecommerce_pkg AS

    -- --------------------------------------------------------
    FUNCTION calculate_discount (
        p_user_id      IN users.user_id%TYPE,
        p_order_amount IN NUMBER
    ) RETURN NUMBER
    AS
        v_tier VARCHAR2(20);
        v_pct  NUMBER := 0;
    BEGIN
        v_tier := get_customer_level(p_user_id);

        v_pct := CASE v_tier
            WHEN 'PLATINUM' THEN 15
            WHEN 'GOLD'     THEN 10
            WHEN 'SILVER'   THEN 5
            WHEN 'BRONZE'   THEN 2
            ELSE 0
        END;

        RETURN ROUND(p_order_amount * v_pct / 100, 2);
    END;

    -- --------------------------------------------------------
    FUNCTION get_customer_level (
        p_user_id IN users.user_id%TYPE
    ) RETURN VARCHAR2
    AS
        v_spend NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(total_amount), 0)
          INTO v_spend
          FROM orders
         WHERE user_id = p_user_id
           AND status NOT IN ('CANCELLED','RETURNED','REFUNDED');

        RETURN CASE
            WHEN v_spend >= 5000 THEN 'PLATINUM'
            WHEN v_spend >= 2000 THEN 'GOLD'
            WHEN v_spend >= 500  THEN 'SILVER'
            WHEN v_spend > 0     THEN 'BRONZE'
            ELSE 'NEW'
        END;
    END;

    -- --------------------------------------------------------
    PROCEDURE order_summary (
        p_order_id IN orders.order_id%TYPE
    )
    AS
    BEGIN
        FOR rec IN (
            SELECT o.order_id, u.name, o.status, o.total_amount, o.order_date
              FROM orders o
              JOIN users u ON o.user_id = u.user_id
             WHERE o.order_id = p_order_id
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Order #' || rec.order_id ||
                ' | ' || rec.name ||
                ' | ' || rec.status ||
                ' | ' || rec.total_amount
            );
        END LOOP;
    END;

    -- --------------------------------------------------------
    PROCEDURE inventory_alert (
        p_category_id IN categories.category_id%TYPE,
        p_threshold   IN NUMBER DEFAULT 15
    )
    AS
    BEGIN
        FOR rec IN (
            SELECT p.product_id, p.name, i.stock_quantity
              FROM products p
              JOIN inventory i ON p.product_id = i.product_id
             WHERE p.category_id = p_category_id
               AND i.stock_quantity <= p_threshold
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                rec.product_id || ' | ' ||
                rec.name || ' | ' ||
                rec.stock_quantity
            );
        END LOOP;
    END;

    -- --------------------------------------------------------
    PROCEDURE bulk_restock_category (
        p_category_id   IN categories.category_id%TYPE,
        p_restock_qty   IN NUMBER DEFAULT 100,
        p_threshold     IN NUMBER DEFAULT 20
    )
    AS
    BEGIN
        UPDATE inventory i
           SET stock_quantity = stock_quantity + p_restock_qty
         WHERE i.product_id IN (
            SELECT p.product_id
              FROM products p
             WHERE p.category_id = p_category_id
               AND i.stock_quantity <= p_threshold
         );
    END;

    -- --------------------------------------------------------
    FUNCTION get_product_info (
        p_product_id IN products.product_id%TYPE
    ) RETURN VARCHAR2
    AS
        v_info VARCHAR2(500);
    BEGIN
        SELECT p.name
          INTO v_info
          FROM products p
         WHERE p.product_id = p_product_id;

        RETURN v_info;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Not found';
    END;

    -- --------------------------------------------------------
    PROCEDURE top_products_by_revenue (
        p_top_n IN NUMBER DEFAULT 5
    )
    AS
    BEGIN
        FOR rec IN (
            SELECT p.name,
                   SUM(oi.quantity * oi.price) revenue
              FROM order_items oi
              JOIN products p ON oi.product_id = p.product_id
             GROUP BY p.name
             ORDER BY revenue DESC
             FETCH FIRST p_top_n ROWS ONLY
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(rec.name || ' = ' || rec.revenue);
        END LOOP;
    END;

    -- --------------------------------------------------------
    PROCEDURE user_spending_report (
        p_user_id IN users.user_id%TYPE
    )
    AS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('User Report: ' || p_user_id);
    END;

END ecommerce_pkg;
/

-- ============================================================
-- SECTION 6: VIEWS (FIXED COMPLETE FILE)
-- ============================================================

-- ------------------------------------------------------------
-- 6.1 Order Summary View
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
    o.order_id,
    o.order_date,
    o.status AS order_status,
    o.total_amount,
    u.user_id,
    u.name AS customer_name,
    u.email,
    COUNT(oi.order_item_id) AS item_count,
    NVL(SUM(oi.quantity), 0) AS total_units,
    p.payment_method,
    p.payment_status,
    s.tracking_number,
    s.courier_name,
    s.shipment_status
FROM orders o
JOIN users u
    ON o.user_id = u.user_id
JOIN order_items oi
    ON o.order_id = oi.order_id
LEFT JOIN payments p
    ON o.order_id = p.order_id
LEFT JOIN shipments s
    ON o.order_id = s.order_id
GROUP BY
    o.order_id,
    o.order_date,
    o.status,
    o.total_amount,
    u.user_id,
    u.name,
    u.email,
    p.payment_method,
    p.payment_status,
    s.tracking_number,
    s.courier_name,
    s.shipment_status;
/    
-- ------------------------------------------------------------ 
-- 6.2 Customer Spending View
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_customer_spending AS
SELECT
    u.user_id,
    u.name AS customer_name,
    u.email,
    u.phone,
    u.created_at AS member_since,
    COUNT(DISTINCT o.order_id) AS total_orders,
    NVL(SUM(CASE
        WHEN o.status NOT IN ('CANCELLED','RETURNED','REFUNDED')
        THEN o.total_amount
    END), 0) AS lifetime_spend,
    ROUND(NVL(AVG(CASE
        WHEN o.status NOT IN ('CANCELLED','RETURNED','REFUNDED')
        THEN o.total_amount
    END), 0), 2) AS avg_order_value,
    MAX(o.order_date) AS last_order_date,
    CASE
        WHEN NVL(SUM(CASE WHEN o.status NOT IN ('CANCELLED','RETURNED','REFUNDED') THEN o.total_amount END), 0) >= 5000 THEN 'PLATINUM'
        WHEN NVL(SUM(CASE WHEN o.status NOT IN ('CANCELLED','RETURNED','REFUNDED') THEN o.total_amount END), 0) >= 2000 THEN 'GOLD'
        WHEN NVL(SUM(CASE WHEN o.status NOT IN ('CANCELLED','RETURNED','REFUNDED') THEN o.total_amount END), 0) >= 500 THEN 'SILVER'
        WHEN NVL(SUM(CASE WHEN o.status NOT IN ('CANCELLED','RETURNED','REFUNDED') THEN o.total_amount END), 0) > 0 THEN 'BRONZE'
        ELSE 'NEW'
    END AS customer_tier
FROM users u
LEFT JOIN orders o
    ON u.user_id = o.user_id
GROUP BY
    u.user_id,
    u.name,
    u.email,
    u.phone,
    u.created_at
/

-- ------------------------------------------------------------
-- 6.3 Product Inventory View
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_product_inventory AS
SELECT
    p.product_id,
    p.name AS product_name,
    c.category_name,
    p.price,
    p.description,
    i.stock_quantity,
    i.last_updated AS stock_last_updated,
    COUNT(DISTINCT pi.image_id) AS image_count,
    ROUND(NVL(AVG(r.rating), 0), 2) AS avg_rating,
    COUNT(DISTINCT r.review_id) AS review_count,
    CASE
        WHEN NVL(i.stock_quantity,0) = 0 THEN 'OUT OF STOCK'
        WHEN NVL(i.stock_quantity,0) <= 10 THEN 'CRITICAL'
        WHEN NVL(i.stock_quantity,0) <= 20 THEN 'LOW'
        WHEN NVL(i.stock_quantity,0) <= 50 THEN 'MODERATE'
        ELSE 'HEALTHY'
    END AS stock_status
FROM products p
JOIN categories c
    ON p.category_id = c.category_id
LEFT JOIN inventory i
    ON p.product_id = i.product_id
LEFT JOIN product_images pi
    ON p.product_id = pi.product_id
LEFT JOIN reviews r
    ON p.product_id = r.product_id
GROUP BY
    p.product_id,
    p.name,
    c.category_name,
    p.price,
    p.description,
    i.stock_quantity,
    i.last_updated
/

-- ------------------------------------------------------------
-- 6.4 Top Products View
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_top_products AS
SELECT
    p.product_id,
    p.name AS product_name,
    c.category_name,
    p.price,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.price) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS order_appearances,
    ROUND(NVL(AVG(r.rating), 0), 2) AS avg_rating,
    COUNT(DISTINCT w.wishlist_id) AS wishlist_count,
    RANK() OVER (
        ORDER BY SUM(oi.quantity * oi.price) DESC
    ) AS revenue_rank
FROM products p
JOIN categories c
    ON p.category_id = c.category_id
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
LEFT JOIN reviews r
    ON p.product_id = r.product_id
LEFT JOIN wishlists w
    ON p.product_id = w.product_id
WHERE o.status NOT IN ('CANCELLED', 'RETURNED', 'REFUNDED')
GROUP BY
    p.product_id,
    p.name,
    c.category_name,
    p.price
/

-- ------------------------------------------------------------
-- 6.5 Payment Summary View
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_payment_summary AS
SELECT
    p.payment_id,
    p.order_id,
    p.payment_method,
    p.payment_status,
    p.payment_date,
    p.amount,
    o.status AS order_status,
    u.user_id,
    u.name AS customer_name,
    u.email
FROM payments p
JOIN orders o
    ON p.order_id = o.order_id
JOIN users u
    ON o.user_id = u.user_id
/

-- ------------------------------------------------------------
-- 6.6 Shipping Status View
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_shipping_status AS
SELECT
    s.shipment_id,
    s.order_id,
    s.tracking_number,
    s.courier_name,
    s.shipment_status,
    s.shipped_date,
    s.delivery_date,
    CASE
        WHEN s.delivery_date IS NOT NULL
         AND s.shipped_date IS NOT NULL
        THEN ROUND(s.delivery_date - s.shipped_date, 0)
        ELSE NULL
    END AS delivery_days,
    o.status AS order_status,
    o.total_amount,
    u.name AS customer_name,
    u.email
FROM shipments s
JOIN orders o
    ON s.order_id = o.order_id
JOIN users u
    ON o.user_id = u.user_id
/


-- ============================================================
-- SECTION 7: ADVANCED ANALYTICS QUERIES (FIXED)
-- ============================================================

-- ------------------------------------------------------------
-- 7.1 Top-Selling Product per Category using RANK()
-- ------------------------------------------------------------
SELECT *
FROM (
    SELECT
        c.category_name,
        p.product_id,
        p.name AS product_name,
        SUM(oi.quantity * oi.price) AS revenue,
        SUM(oi.quantity) AS units_sold,
        RANK() OVER (
            PARTITION BY c.category_id
            ORDER BY SUM(oi.quantity * oi.price) DESC
        ) AS revenue_rank
    FROM products p
    JOIN categories c ON p.category_id = c.category_id
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status NOT IN ('CANCELLED', 'RETURNED', 'REFUNDED')
    GROUP BY c.category_id, c.category_name, p.product_id, p.name
)
WHERE revenue_rank = 1
ORDER BY revenue DESC
/

-- ------------------------------------------------------------
-- 7.2 Customer Segmentation with DENSE_RANK()
-- ------------------------------------------------------------
SELECT
    user_id,
    customer_name,
    email,
    lifetime_spend,
    total_orders,
    customer_tier,
    DENSE_RANK() OVER (ORDER BY lifetime_spend DESC) AS spend_rank,
    DENSE_RANK() OVER (ORDER BY total_orders DESC) AS order_rank
FROM vw_customer_spending
WHERE total_orders > 0
ORDER BY spend_rank
/

-- ------------------------------------------------------------
-- 7.3 Monthly Revenue Growth with LAG()
-- ------------------------------------------------------------
WITH monthly_revenue AS (
    SELECT
        TO_CHAR(order_date, 'YYYY-MM') AS month_label,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status NOT IN ('CANCELLED', 'RETURNED', 'REFUNDED')
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT
    month_label,
    revenue,
    LAG(revenue) OVER (ORDER BY month_label) AS prev_month_revenue,

    ROUND(
        revenue - NVL(LAG(revenue) OVER (ORDER BY month_label), 0),
        2
    ) AS revenue_change,

    ROUND(
        (revenue - NVL(LAG(revenue) OVER (ORDER BY month_label), 0))
        / NULLIF(NVL(LAG(revenue) OVER (ORDER BY month_label), 0), 0) * 100,
        2
    ) AS growth_pct
FROM monthly_revenue
ORDER BY month_label
/

-- ------------------------------------------------------------
-- 7.4 Running Total Revenue per Customer
-- ------------------------------------------------------------
SELECT
    u.user_id,
    u.name AS customer_name,
    o.order_id,
    o.order_date,
    o.total_amount,
    ROW_NUMBER() OVER (
        PARTITION BY u.user_id ORDER BY o.order_date
    ) AS order_sequence,

    SUM(o.total_amount) OVER (
        PARTITION BY u.user_id
        ORDER BY o.order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE o.status NOT IN ('CANCELLED', 'RETURNED', 'REFUNDED')
ORDER BY u.user_id, o.order_date
/

-- ------------------------------------------------------------
-- 7.5 Repeat Customers (CTE)
-- ------------------------------------------------------------
WITH order_counts AS (
    SELECT
        user_id,
        COUNT(order_id) AS order_count,
        SUM(total_amount) AS total_spent,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order
    FROM orders
    WHERE status NOT IN ('CANCELLED', 'RETURNED', 'REFUNDED')
    GROUP BY user_id
    HAVING COUNT(order_id) > 1
)
SELECT
    u.user_id,
    u.name,
    u.email,
    oc.order_count,
    ROUND(oc.total_spent, 2) AS lifetime_value,
    TO_CHAR(oc.first_order, 'DD-MON-YYYY') AS first_purchase,
    TO_CHAR(oc.last_order, 'DD-MON-YYYY') AS latest_purchase,
    ROUND(oc.last_order - oc.first_order, 0) AS customer_lifespan_days
FROM order_counts oc
JOIN users u ON oc.user_id = u.user_id
ORDER BY oc.order_count DESC, oc.total_spent DESC
/

-- ------------------------------------------------------------
-- 7.6 Above-Average Revenue Products
-- ------------------------------------------------------------
SELECT
    p.product_id,
    p.name AS product_name,
    c.category_name,
    SUM(oi.quantity * oi.price) AS product_revenue
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status NOT IN ('CANCELLED', 'RETURNED', 'REFUNDED')
GROUP BY p.product_id, p.name, c.category_name
HAVING SUM(oi.quantity * oi.price) > (
    SELECT AVG(product_total)
    FROM (
        SELECT SUM(oi2.quantity * oi2.price) AS product_total
        FROM order_items oi2
        JOIN orders o2 ON oi2.order_id = o2.order_id
        WHERE o2.status NOT IN ('CANCELLED', 'RETURNED', 'REFUNDED')
        GROUP BY oi2.product_id
    )
)
ORDER BY product_revenue DESC
/

-- ------------------------------------------------------------
-- 7.7 Category Revenue Share
-- ------------------------------------------------------------
SELECT
    c.category_name,
    SUM(oi.quantity * oi.price) AS category_revenue,

    ROUND(
        RATIO_TO_REPORT(SUM(oi.quantity * oi.price)) OVER () * 100,
        2
    ) AS revenue_share_pct,

    RANK() OVER (
        ORDER BY SUM(oi.quantity * oi.price) DESC
    ) AS rank_by_revenue
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status NOT IN ('CANCELLED', 'RETURNED', 'REFUNDED')
GROUP BY c.category_id, c.category_name
ORDER BY rank_by_revenue
/

-- ------------------------------------------------------------
-- 7.8 N-Tile Customer Segments (Quartiles)
-- ------------------------------------------------------------
SELECT
    user_id,
    customer_name,
    lifetime_spend,

    NTILE(4) OVER (ORDER BY lifetime_spend DESC) AS spend_quartile,

    CASE NTILE(4) OVER (ORDER BY lifetime_spend DESC)
        WHEN 1 THEN 'Top 25%'
        WHEN 2 THEN 'Upper-Mid 25%'
        WHEN 3 THEN 'Lower-Mid 25%'
        WHEN 4 THEN 'Bottom 25%'
    END AS quartile_label
FROM vw_customer_spending
WHERE lifetime_spend > 0
ORDER BY lifetime_spend DESC
/

-- ------------------------------------------------------------
-- 7.9 Wishlist to Order Conversion Rate
-- ------------------------------------------------------------
WITH wishlist_counts AS (
    SELECT product_id, COUNT(*) AS wishlisted_by
    FROM wishlists
    GROUP BY product_id
),
order_counts AS (
    SELECT oi.product_id, COUNT(DISTINCT o.user_id) AS ordered_by
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status NOT IN ('CANCELLED', 'RETURNED', 'REFUNDED')
    GROUP BY oi.product_id
)
SELECT
    p.product_id,
    p.name AS product_name,
    NVL(wl.wishlisted_by, 0) AS wishlist_count,
    NVL(oc.ordered_by, 0) AS order_count,

    ROUND(
        NVL(oc.ordered_by, 0) * 100.0
        / NULLIF(NVL(wl.wishlisted_by, 0), 0),
        2
    ) AS conversion_rate_pct
FROM products p
LEFT JOIN wishlist_counts wl ON p.product_id = wl.product_id
LEFT JOIN order_counts oc ON p.product_id = oc.product_id
WHERE NVL(wl.wishlisted_by, 0) > 0
ORDER BY conversion_rate_pct DESC NULLS LAST
/

-- ============================================================
-- SECTION 8: INDEXES + PERFORMANCE OPTIMIZATION (FIXED)
-- ============================================================

-- Foreign key indexes
CREATE INDEX idx_addresses_user_id     ON addresses (user_id);
CREATE INDEX idx_orders_user_id        ON orders (user_id);
CREATE INDEX idx_order_items_order_id  ON order_items (order_id);
CREATE INDEX idx_order_items_product   ON order_items (product_id);
CREATE INDEX idx_payments_order_id     ON payments (order_id);
CREATE INDEX idx_shipments_order_id    ON shipments (order_id);
CREATE INDEX idx_cart_user_id          ON cart_items (user_id);
CREATE INDEX idx_cart_product_id       ON cart_items (product_id);
CREATE INDEX idx_wishlist_user_id      ON wishlists (user_id);
CREATE INDEX idx_wishlist_product_id   ON wishlists (product_id);
CREATE INDEX idx_reviews_product_id    ON reviews (product_id);
CREATE INDEX idx_reviews_user_id       ON reviews (user_id);
CREATE INDEX idx_inventory_product_id  ON inventory (product_id);
CREATE INDEX idx_product_images_prod   ON product_images (product_id);
CREATE INDEX idx_products_category_id  ON products (category_id);
CREATE INDEX idx_status_hist_order_id  ON order_status_history (order_id);

-- Functional / performance indexes
CREATE INDEX idx_users_email_lower
ON users (LOWER(email));

CREATE INDEX idx_orders_date
ON orders (order_date DESC);

CREATE INDEX idx_orders_status
ON orders (status);

CREATE INDEX idx_payments_status
ON payments (payment_status);

CREATE INDEX idx_payments_date
ON payments (payment_date DESC);

CREATE INDEX idx_shipments_tracking
ON shipments (tracking_number);

CREATE INDEX idx_shipments_status
ON shipments (shipment_status);

CREATE INDEX idx_products_price
ON products (price);

-- Composite indexes
CREATE INDEX idx_orders_user_status
ON orders (user_id, status);

CREATE INDEX idx_oi_order_product
ON order_items (order_id, product_id);

-- EXPLAIN PLAN
EXPLAIN PLAN FOR
SELECT u.name, o.order_id, o.total_amount
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE o.status = 'DELIVERED'
AND o.order_date >= SYSDATE - 30;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR
SELECT p.name, SUM(oi.quantity * oi.price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'DELIVERED'
GROUP BY p.name
ORDER BY revenue DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Gather statistics
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'ORDERS');
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'ORDER_ITEMS');
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PRODUCTS');
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'USERS');
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'INVENTORY');
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PAYMENTS');
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'SHIPMENTS');

    DBMS_OUTPUT.PUT_LINE('Statistics gathered successfully.');
END;
/

-- ============================================================
-- SECTION 9: TRANSACTION CONTROL & SAVEPOINTS (FIXED)
-- ============================================================

-- ------------------------------------------------------------
-- 9.1 SAVEPOINT DEMO
-- ------------------------------------------------------------
DECLARE
    v_order_id NUMBER;
    v_stock    NUMBER;
BEGIN
    v_order_id := seq_orders.NEXTVAL;

    INSERT INTO orders (order_id, user_id, order_date, total_amount, status)
    VALUES (v_order_id, 2, SYSDATE, 0, 'PENDING');

    SAVEPOINT sp_order_created;

    INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
    VALUES (seq_order_items.NEXTVAL, v_order_id, 10, 1, 99.99);

    SAVEPOINT sp_item_added;

    BEGIN
        SELECT stock_quantity
        INTO v_stock
        FROM inventory
        WHERE product_id = 99
        FOR UPDATE;

        IF v_stock < 500 THEN
            DBMS_OUTPUT.PUT_LINE('Not enough stock. Rolling back item insertion.');
            ROLLBACK TO sp_item_added;
        ELSE
            INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
            VALUES (seq_order_items.NEXTVAL, v_order_id, 99, 500, 5.99);
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Product 99 not found.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Inventory lock issue: ' || SQLERRM);
    END;

    UPDATE orders
    SET total_amount =
        NVL((SELECT SUM(quantity * price)
             FROM order_items
             WHERE order_id = v_order_id), 0),
        status = 'CONFIRMED'
    WHERE order_id = v_order_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Order committed: ' || v_order_id);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Transaction failed: ' || SQLERRM);
END;
/

-- ------------------------------------------------------------
-- 9.2 CONCURRENT SAFE INVENTORY UPDATE
-- ------------------------------------------------------------
DECLARE
    v_product_id NUMBER := 1;
    v_qty_needed NUMBER := 5;
    v_stock      NUMBER;
    v_order_id   NUMBER;
BEGIN
    BEGIN
        SELECT stock_quantity
        INTO v_stock
        FROM inventory
        WHERE product_id = v_product_id
        FOR UPDATE NOWAIT;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Row locked by another session.');
            RETURN;
    END;

    IF v_stock < v_qty_needed THEN
        RAISE_APPLICATION_ERROR(-20300, 'Insufficient stock.');
    END IF;

    v_order_id := seq_orders.NEXTVAL;

    INSERT INTO orders (order_id, user_id, order_date, total_amount, status)
    VALUES (v_order_id, 3, SYSDATE, v_qty_needed * 1299.99, 'CONFIRMED');

    INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
    VALUES (seq_order_items.NEXTVAL, v_order_id, v_product_id, v_qty_needed, 1299.99);

    UPDATE inventory
    SET stock_quantity = stock_quantity - v_qty_needed,
        last_updated = SYSDATE
    WHERE product_id = v_product_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Order placed safely: ' || v_order_id);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- ------------------------------------------------------------
-- 9.3 FULL ROLLBACK DEMO
-- ------------------------------------------------------------
DECLARE
    v_order_id NUMBER;
BEGIN
    v_order_id := seq_orders.NEXTVAL;

    INSERT INTO orders (order_id, user_id, order_date, total_amount, status)
    VALUES (v_order_id, 4, SYSDATE, 500, 'PENDING');

    SAVEPOINT sp1;

    INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
    VALUES (seq_order_items.NEXTVAL, v_order_id, 1, 1, 500);

    SAVEPOINT sp2;

    -- Force error
    UPDATE inventory
    SET stock_quantity = -9999
    WHERE product_id = 1;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('FULL ROLLBACK executed: ' || SQLERRM);
END;
/

-- ============================================================
-- SECTION 10: AUDIT / LOGGING (FIXED VERSION)
-- ============================================================

-- ------------------------------------------------------------
-- 10.1 Audit table for order changes
-- ------------------------------------------------------------
CREATE TABLE audit_orders (
    audit_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id      NUMBER,
    changed_by    VARCHAR2(100)   DEFAULT USER,
    change_type   VARCHAR2(10),   -- INSERT / UPDATE / DELETE
    old_status    VARCHAR2(50),
    new_status    VARCHAR2(50),
    old_amount    NUMBER(12,2),
    new_amount    NUMBER(12,2),
    changed_at    DATE            DEFAULT SYSDATE
);

-- ------------------------------------------------------------
-- 10.2 Audit table for product price changes
-- ------------------------------------------------------------
CREATE TABLE audit_product_prices (
    audit_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id    NUMBER,
    product_name  VARCHAR2(255),
    old_price     NUMBER(12,2),
    new_price     NUMBER(12,2),
    changed_by    VARCHAR2(100)   DEFAULT USER,
    changed_at    DATE            DEFAULT SYSDATE
);

-- ------------------------------------------------------------
-- 10.3 Audit table for inventory changes
-- ------------------------------------------------------------
CREATE TABLE audit_inventory (
    audit_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id      NUMBER,
    operation       VARCHAR2(10),
    old_quantity    NUMBER,
    new_quantity    NUMBER,
    quantity_change NUMBER,
    changed_by      VARCHAR2(100) DEFAULT USER,
    changed_at      DATE          DEFAULT SYSDATE
);

-- ============================================================
-- 10.4 Trigger: Audit Orders (FIXED NULL SAFE VERSION)
-- ============================================================
CREATE OR REPLACE TRIGGER trg_audit_orders
AFTER INSERT OR UPDATE OR DELETE ON orders
FOR EACH ROW
DECLARE
    v_type VARCHAR2(10);
BEGIN
    IF INSERTING THEN
        v_type := 'INSERT';
    ELSIF UPDATING THEN
        v_type := 'UPDATE';
    ELSIF DELETING THEN
        v_type := 'DELETE';
    END IF;

    INSERT INTO audit_orders (
        order_id,
        changed_by,
        change_type,
        old_status,
        new_status,
        old_amount,
        new_amount,
        changed_at
    )
    VALUES (
        NVL(:NEW.order_id, :OLD.order_id),
        USER,
        v_type,
        :OLD.status,
        :NEW.status,
        :OLD.total_amount,
        :NEW.total_amount,
        SYSDATE
    );

EXCEPTION
    WHEN OTHERS THEN
        NULL; -- never block main transaction
END;
/
-- ============================================================
-- 10.5 Trigger: Audit Product Price Changes (SAFE)
-- ============================================================
CREATE OR REPLACE TRIGGER trg_audit_product_price
AFTER UPDATE OF price ON products
FOR EACH ROW
BEGIN
    IF NVL(:OLD.price, 0) != NVL(:NEW.price, 0) THEN
        INSERT INTO audit_product_prices (
            product_id,
            product_name,
            old_price,
            new_price,
            changed_by,
            changed_at
        )
        VALUES (
            :NEW.product_id,
            :NEW.name,
            :OLD.price,
            :NEW.price,
            USER,
            SYSDATE
        );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/
-- ============================================================
-- 10.6 Trigger: Audit Inventory Changes (FIXED OPERATION LOGIC)
-- ============================================================
CREATE OR REPLACE TRIGGER trg_audit_inventory
AFTER UPDATE OF stock_quantity ON inventory
FOR EACH ROW
BEGIN
    INSERT INTO audit_inventory (
        product_id,
        operation,
        old_quantity,
        new_quantity,
        quantity_change,
        changed_by,
        changed_at
    )
    VALUES (
        :NEW.product_id,
        CASE
            WHEN :NEW.stock_quantity > :OLD.stock_quantity THEN 'RESTOCK'
            WHEN :NEW.stock_quantity < :OLD.stock_quantity THEN 'DEDUCT'
            ELSE 'NOCHANGE'
        END,
        :OLD.stock_quantity,
        :NEW.stock_quantity,
        :NEW.stock_quantity - :OLD.stock_quantity,
        USER,
        SYSDATE
    );

EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/
-- ============================================================
-- 10.7 REPORTING QUERIES (FIXED)
-- ============================================================

-- Order audit trail
SELECT
    audit_id,
    order_id,
    change_type,
    old_status,
    new_status,
    old_amount,
    new_amount,
    changed_by,
    TO_CHAR(changed_at, 'DD-MON-YYYY HH24:MI:SS') AS changed_at
FROM audit_orders
ORDER BY changed_at DESC;

-- Product price history (FIXED DIVISION SAFETY)
SELECT
    product_id,
    product_name,
    old_price,
    new_price,
    NVL(new_price - old_price, 0) AS price_delta,
    CASE
        WHEN old_price IS NULL OR old_price = 0 THEN NULL
        ELSE ROUND(((new_price - old_price) / old_price) * 100, 2)
    END AS pct_change,
    changed_by,
    TO_CHAR(changed_at, 'DD-MON-YYYY HH24:MI:SS') AS changed_at
FROM audit_product_prices
ORDER BY changed_at DESC;

-- Inventory audit log
SELECT
    ai.audit_id,
    ai.product_id,
    p.name AS product_name,
    ai.operation,
    ai.old_quantity,
    ai.new_quantity,
    ai.quantity_change,
    ai.changed_by,
    TO_CHAR(ai.changed_at, 'DD-MON-YYYY HH24:MI:SS') AS changed_at
FROM audit_inventory ai
JOIN products p ON ai.product_id = p.product_id
ORDER BY ai.changed_at DESC;

-- Inventory summary
SELECT
    ai.product_id,
    p.name AS product_name,
    SUM(CASE WHEN ai.operation = 'RESTOCK' THEN ai.quantity_change ELSE 0 END) AS total_restocked,
    SUM(CASE WHEN ai.operation = 'DEDUCT' THEN ABS(ai.quantity_change) ELSE 0 END) AS total_deducted,
    COUNT(*) AS change_events
FROM audit_inventory ai
JOIN products p ON ai.product_id = p.product_id
GROUP BY ai.product_id, p.name
ORDER BY total_deducted DESC;