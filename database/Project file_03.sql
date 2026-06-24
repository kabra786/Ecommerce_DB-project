SELECT
    table_name,
    constraint_name,
    constraint_type,
    status,
    validated
FROM user_constraints
WHERE table_name IN (
    'USERS', 'ORDERS', 'ORDER_ITEMS', 'PRODUCTS',
    'INVENTORY', 'PAYMENTS', 'REVIEWS', 'CART_ITEMS', 'WISHLISTS'
)
ORDER BY table_name, constraint_type;
*/

-- ------------------------------------------------------------
-- 1.2 Users → Addresses (LEFT JOIN)
-- Reveals users who have NOT registered any address yet
-- ------------------------------------------------------------
SELECT
    u.user_id,
    u.name                  AS user_name,
    u.email,
    a.address_id,
    a.city
FROM users u
LEFT JOIN addresses a ON u.user_id = a.user_id
ORDER BY a.address_id NULLS FIRST;

-- ------------------------------------------------------------
-- 1.3 Orphan Detection: Addresses without a valid User
-- Should return 0 rows in a clean database
-- ------------------------------------------------------------
SELECT
    a.address_id,
    a.user_id,
    a.full_address
FROM addresses a
LEFT JOIN users u ON a.user_id = u.user_id
WHERE u.user_id IS NULL;

-- ------------------------------------------------------------
-- 1.4 Users → Orders (INNER JOIN)
-- Shows all users who have placed at least one order
-- ------------------------------------------------------------
SELECT
    u.user_id,
    u.name                  AS user_name,
    u.email,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.status                AS order_status
FROM users u
JOIN orders o ON u.user_id = o.user_id
ORDER BY o.order_date DESC;

-- ------------------------------------------------------------
-- 1.5 Users → Orders (LEFT JOIN)
-- Finds users who have NEVER placed an order (potential targets)
-- ------------------------------------------------------------
SELECT
    u.user_id,
    u.name                  AS user_name,
    u.email,
    u.phone,
    o.order_id
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
WHERE o.order_id IS NULL
ORDER BY u.user_id;

-- ------------------------------------------------------------
-- 1.6 Orphan Detection: Orders without a valid User
-- Should return 0 rows in a healthy database
-- ------------------------------------------------------------
SELECT
    o.order_id,
    o.user_id,
    o.total_amount,
    o.status
FROM orders o
LEFT JOIN users u ON o.user_id = u.user_id
WHERE u.user_id IS NULL;

-- ------------------------------------------------------------
-- 1.7 Products → Orders via Order_Items (3-table JOIN)
-- Full purchase trail: which products were ordered by whom
-- ------------------------------------------------------------
SELECT
    u.user_id,
    u.name                  AS user_name,
    o.order_id,
    o.order_date,
    o.status                AS order_status,
    p.product_id,
    p.name                  AS product_name,
    oi.quantity,
    oi.price                AS unit_price,
    (oi.quantity * oi.price) AS line_total
FROM users u
JOIN orders     o  ON u.user_id    = o.user_id
JOIN order_items oi ON o.order_id  = oi.order_id
JOIN products   p  ON oi.product_id = p.product_id
ORDER BY o.order_date DESC, o.order_id;

-- ------------------------------------------------------------
-- 1.8 Products → Orders: LEFT JOIN
-- Products that have NEVER been ordered
-- ------------------------------------------------------------
SELECT
    p.product_id,
    p.name                  AS product_name,
    p.price,
    c.category_name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
JOIN categories c        ON p.category_id = c.category_id
WHERE oi.order_item_id IS NULL
ORDER BY p.product_id;

-- ------------------------------------------------------------
-- 1.9 Orphan Detection: Order_Items with no matching Order
-- Should return 0 rows
-- ------------------------------------------------------------
SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- ------------------------------------------------------------
-- 1.10 Orphan Detection: Order_Items with no matching Product
-- Should return 0 rows
-- ------------------------------------------------------------
SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- ------------------------------------------------------------
-- 1.11 Products → Inventory (INNER JOIN)
-- Every product alongside its current stock level
-- ------------------------------------------------------------
SELECT
    p.product_id,
    p.name                  AS product_name,
    c.category_name,
    p.price,
    i.stock_quantity,
    i.last_updated,
    CASE
        WHEN i.stock_quantity = 0   THEN 'OUT OF STOCK'
        WHEN i.stock_quantity < 20  THEN 'LOW STOCK'
        WHEN i.stock_quantity < 100 THEN 'MODERATE STOCK'
        ELSE                             'WELL STOCKED'
    END                     AS stock_status
FROM products p
JOIN inventory  i ON p.product_id  = i.product_id
JOIN categories c ON p.category_id = c.category_id
ORDER BY i.stock_quantity ASC;

-- ------------------------------------------------------------
-- 1.12 Orphan Detection: Inventory rows with no Product
-- Should return 0 rows
-- ------------------------------------------------------------
SELECT
    i.inventory_id,
    i.product_id,
    i.stock_quantity
FROM inventory i
LEFT JOIN products p ON i.product_id = p.product_id
WHERE p.product_id IS NULL;

-- ------------------------------------------------------------
-- 1.13 Products with no Inventory record (data gap check)
-- Should return 0 rows after a clean Stage 1 load
-- ------------------------------------------------------------
SELECT
    p.product_id,
    p.name AS product_name
FROM products p
LEFT JOIN inventory i ON p.product_id = i.product_id
WHERE i.inventory_id IS NULL;

-- ------------------------------------------------------------
-- 1.14 Users → Cart_Items (INNER JOIN)
-- Active cart contents per user
-- ------------------------------------------------------------
SELECT
    u.user_id,
    u.name                  AS user_name,
    p.product_id,
    p.name                  AS product_name,
    ci.quantity,
    p.price                 AS unit_price,
    (ci.quantity * p.price) AS cart_line_total,
    ci.added_at
FROM users u
JOIN cart_items ci ON u.user_id    = ci.user_id
JOIN products   p  ON ci.product_id = p.product_id
ORDER BY u.user_id, ci.added_at DESC;

-- ------------------------------------------------------------
-- 1.15 Cart_Items: Orphan Detection (no valid User)
-- Should return 0 rows
-- ------------------------------------------------------------
SELECT
    ci.cart_item_id,
    ci.user_id,
    ci.product_id
FROM cart_items ci
LEFT JOIN users u ON ci.user_id = u.user_id
WHERE u.user_id IS NULL;

-- ------------------------------------------------------------
-- 1.16 Users → Wishlists (INNER JOIN)
-- Full wishlist view with product details
-- ------------------------------------------------------------
SELECT
    u.user_id,
    u.name                  AS user_name,
    p.product_id,
    p.name                  AS product_name,
    c.category_name,
    p.price,
    w.added_at              AS wishlisted_on
FROM users u
JOIN wishlists  w ON u.user_id    = w.user_id
JOIN products   p ON w.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
ORDER BY u.user_id, w.added_at DESC;

-- ------------------------------------------------------------
-- 1.17 Wishlist Orphan Detection (no valid User or Product)
-- Should return 0 rows for both checks
-- ------------------------------------------------------------
SELECT w.wishlist_id, w.user_id, w.product_id, 'MISSING USER' AS issue
FROM wishlists w
LEFT JOIN users u ON w.user_id = u.user_id
WHERE u.user_id IS NULL
UNION ALL
SELECT w.wishlist_id, w.user_id, w.product_id, 'MISSING PRODUCT' AS issue
FROM wishlists w
LEFT JOIN products p ON w.product_id = p.product_id
WHERE p.product_id IS NULL;


-- ============================================================
-- SECTION 2: REAL TRANSACTION SIMULATIONS
-- ============================================================

-- ------------------------------------------------------------
-- TRANSACTION 1
-- Customer (user_id=1) purchases:
--   → Samsung Galaxy S24 Ultra (product_id=1, qty=1, price=1299.99)
--   → Sony WH-1000XM5 Headphones (product_id=3, qty=1, price=349.99)
-- Total: 1649.98
-- ------------------------------------------------------------
DECLARE
    v_order_id    NUMBER;
    v_stock_1     NUMBER;
    v_stock_3     NUMBER;
    v_qty_1       NUMBER := 1;
    v_qty_3       NUMBER := 1;
    v_price_1     NUMBER := 1299.99;
    v_price_3     NUMBER := 349.99;
    v_total       NUMBER := (v_price_1 * v_qty_1) + (v_price_3 * v_qty_3);
BEGIN
    -- Step 1: Lock and verify stock availability
    SELECT stock_quantity INTO v_stock_1
    FROM inventory
    WHERE product_id = 1
    FOR UPDATE;

    SELECT stock_quantity INTO v_stock_3
    FROM inventory
    WHERE product_id = 3
    FOR UPDATE;

    IF v_stock_1 < v_qty_1 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient stock for product_id=1');
    END IF;

    IF v_stock_3 < v_qty_3 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Insufficient stock for product_id=3');
    END IF;

    -- Step 2: Create the order
    v_order_id := seq_orders.NEXTVAL;

    INSERT INTO orders (order_id, user_id, order_date, total_amount, status)
    VALUES (v_order_id, 1, SYSDATE, v_total, 'CONFIRMED');

    -- Step 3: Insert order line items
    INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
    VALUES (seq_order_items.NEXTVAL, v_order_id, 1, v_qty_1, v_price_1);

    INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
    VALUES (seq_order_items.NEXTVAL, v_order_id, 3, v_qty_3, v_price_3);

    -- Step 4: Deduct inventory
    UPDATE inventory
    SET stock_quantity = stock_quantity - v_qty_1,
        last_updated   = SYSDATE
    WHERE product_id = 1;

    UPDATE inventory
    SET stock_quantity = stock_quantity - v_qty_3,
        last_updated   = SYSDATE
    WHERE product_id = 3;

    -- Step 5: Record payment
    INSERT INTO payments (payment_id, order_id, payment_method, payment_status, payment_date, amount)
    VALUES (seq_payments.NEXTVAL, v_order_id, 'CREDIT_CARD', 'COMPLETED', SYSDATE, v_total);

    -- Step 6: Create shipment record
    INSERT INTO shipments (shipment_id, order_id, tracking_number, courier_name, shipment_status, shipped_date, delivery_date)
    VALUES (seq_shipments.NEXTVAL, v_order_id, 'TRK-NEW-' || v_order_id || '-A', 'DHL Pakistan', 'DISPATCHED', SYSDATE, SYSDATE + 3);

    -- Step 7: Log order status history
    INSERT INTO order_status_history (status_id, order_id, status, updated_at)
    VALUES (seq_status_history.NEXTVAL, v_order_id, 'CONFIRMED', SYSDATE);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('TRANSACTION 1 SUCCESS | order_id=' || v_order_id || ' | total=PKR ' || v_total);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('TRANSACTION 1 FAILED | ' || SQLERRM);
END;
/

-- ------------------------------------------------------------
-- TRANSACTION 2
-- Customer (user_id=5) purchases:
--   → Callaway Golf Club Set   (product_id=56, qty=1, price=249.99)
--   → Coleman 6-Person Tent    (product_id=57, qty=2, price=149.99)
--   → Peloton Yoga Mat         (product_id=54, qty=3, price=44.99)
-- Total: 684.94
-- ------------------------------------------------------------
DECLARE
    v_order_id   NUMBER;
    v_stock_56   NUMBER;
    v_stock_57   NUMBER;
    v_stock_54   NUMBER;
    v_qty_56     NUMBER := 1;
    v_qty_57     NUMBER := 2;
    v_qty_54     NUMBER := 3;
    v_price_56   NUMBER := 249.99;
    v_price_57   NUMBER := 149.99;
    v_price_54   NUMBER := 44.99;
    v_total      NUMBER;
BEGIN
    v_total := (v_price_56 * v_qty_56)
             + (v_price_57 * v_qty_57)
             + (v_price_54 * v_qty_54);

    -- Step 1: Lock rows and check stock
    SELECT stock_quantity INTO v_stock_56 FROM inventory WHERE product_id = 56 FOR UPDATE;
    SELECT stock_quantity INTO v_stock_57 FROM inventory WHERE product_id = 57 FOR UPDATE;
    SELECT stock_quantity INTO v_stock_54 FROM inventory WHERE product_id = 54 FOR UPDATE;

    IF v_stock_56 < v_qty_56 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Insufficient stock for product_id=56');
    END IF;

    IF v_stock_57 < v_qty_57 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Insufficient stock for product_id=57');
    END IF;

    IF v_stock_54 < v_qty_54 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Insufficient stock for product_id=54');
    END IF;

    -- Step 2: Place order
    v_order_id := seq_orders.NEXTVAL;

    INSERT INTO orders (order_id, user_id, order_date, total_amount, status)
    VALUES (v_order_id, 5, SYSDATE, v_total, 'CONFIRMED');

    -- Step 3: Order items
    INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
    VALUES (seq_order_items.NEXTVAL, v_order_id, 56, v_qty_56, v_price_56);

    INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
    VALUES (seq_order_items.NEXTVAL, v_order_id, 57, v_qty_57, v_price_57);

    INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
    VALUES (seq_order_items.NEXTVAL, v_order_id, 54, v_qty_54, v_price_54);

    -- Step 4: Update inventory
    UPDATE inventory SET stock_quantity = stock_quantity - v_qty_56, last_updated = SYSDATE WHERE product_id = 56;
    UPDATE inventory SET stock_quantity = stock_quantity - v_qty_57, last_updated = SYSDATE WHERE product_id = 57;
    UPDATE inventory SET stock_quantity = stock_quantity - v_qty_54, last_updated = SYSDATE WHERE product_id = 54;

    -- Step 5: Payment via Cash on Delivery
    INSERT INTO payments (payment_id, order_id, payment_method, payment_status, payment_date, amount)
    VALUES (seq_payments.NEXTVAL, v_order_id, 'CASH_ON_DELIVERY', 'PENDING', SYSDATE, v_total);

    -- Step 6: Shipment
    INSERT INTO shipments (shipment_id, order_id, tracking_number, courier_name, shipment_status, shipped_date, delivery_date)
    VALUES (seq_shipments.NEXTVAL, v_order_id, 'TRK-NEW-' || v_order_id || '-B', 'TCS Courier', 'PENDING', NULL, NULL);

    -- Step 7: Status log
    INSERT INTO order_status_history (status_id, order_id, status, updated_at)
    VALUES (seq_status_history.NEXTVAL, v_order_id, 'PENDING', SYSDATE - (1/1440));

    INSERT INTO order_status_history (status_id, order_id, status, updated_at)
    VALUES (seq_status_history.NEXTVAL, v_order_id, 'CONFIRMED', SYSDATE);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('TRANSACTION 2 SUCCESS | order_id=' || v_order_id || ' | total=' || v_total);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('TRANSACTION 2 FAILED | ' || SQLERRM);
END;
/

-- ------------------------------------------------------------
-- TRANSACTION 3 (EXPECTED FAILURE CASE)
-- ------------------------------------------------------------
DECLARE
    v_order_id   NUMBER;
    v_stock      NUMBER;
    v_qty        NUMBER := 600;
    v_price      NUMBER := 5.99;
    v_total      NUMBER := v_qty * v_price;
BEGIN
    SELECT stock_quantity INTO v_stock
    FROM inventory
    WHERE product_id = 71
    FOR UPDATE;

    IF v_stock < v_qty THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'STOCK INSUFFICIENT: requested=' || v_qty ||
            ', available=' || v_stock ||
            ' for product_id=71'
        );
    END IF;

    v_order_id := seq_orders.NEXTVAL;

    INSERT INTO orders (order_id, user_id, order_date, total_amount, status)
    VALUES (v_order_id, 10, SYSDATE, v_total, 'CONFIRMED');

    INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
    VALUES (seq_order_items.NEXTVAL, v_order_id, 71, v_qty, v_price);

    UPDATE inventory
    SET stock_quantity = stock_quantity - v_qty,
        last_updated   = SYSDATE
    WHERE product_id = 71;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('TRANSACTION 3 SUCCESS (unexpected)');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('TRANSACTION 3 ROLLED BACK (expected) | ' || SQLERRM);
END;
/

-- ------------------------------------------------------------
-- TRANSACTION 4 (BONUS)
-- Full order lifecycle simulation for user_id=15:
--   → Apple MacBook Air M2 (product_id=5, qty=1, price=1099.99)
-- Demonstrates: order → payment → shipment → status progression
-- ------------------------------------------------------------
DECLARE
    v_order_id   NUMBER;
    v_stock      NUMBER;
    v_qty        NUMBER := 1;
    v_price      NUMBER := 1099.99;
    v_total      NUMBER := v_price * v_qty;
BEGIN
    SELECT stock_quantity INTO v_stock
    FROM inventory
    WHERE product_id = 5
    FOR UPDATE;

    IF v_stock < v_qty THEN
        RAISE_APPLICATION_ERROR(-20011, 'Insufficient stock for MacBook Air M2');
    END IF;

    v_order_id := seq_orders.NEXTVAL;

    INSERT INTO orders (order_id, user_id, order_date, total_amount, status)
    VALUES (v_order_id, 15, SYSDATE, v_total, 'PROCESSING');

    INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
    VALUES (seq_order_items.NEXTVAL, v_order_id, 5, v_qty, v_price);

    UPDATE inventory
    SET stock_quantity = stock_quantity - v_qty,
        last_updated   = SYSDATE
    WHERE product_id = 5;

    -- PayPal payment — completed instantly
    INSERT INTO payments (payment_id, order_id, payment_method, payment_status, payment_date, amount)
    VALUES (seq_payments.NEXTVAL, v_order_id, 'PAYPAL', 'COMPLETED', SYSDATE, v_total);

    -- Shipment created and dispatched same day
    INSERT INTO shipments (shipment_id, order_id, tracking_number, courier_name, shipment_status, shipped_date, delivery_date)
    VALUES (seq_shipments.NEXTVAL, v_order_id, 'TRK-NEW-' || v_order_id || '-C', 'FedEx', 'IN_TRANSIT', SYSDATE, SYSDATE + 5);

    -- Full status history trail
    INSERT INTO order_status_history (status_id, order_id, status, updated_at)
    VALUES (seq_status_history.NEXTVAL, v_order_id, 'PENDING',    SYSDATE - (3/1440));

    INSERT INTO order_status_history (status_id, order_id, status, updated_at)
    VALUES (seq_status_history.NEXTVAL, v_order_id, 'CONFIRMED',  SYSDATE - (2/1440));

    INSERT INTO order_status_history (status_id, order_id, status, updated_at)
    VALUES (seq_status_history.NEXTVAL, v_order_id, 'PROCESSING', SYSDATE - (1/1440));

    INSERT INTO order_status_history (status_id, order_id, status, updated_at)
    VALUES (seq_status_history.NEXTVAL, v_order_id, 'SHIPPED',    SYSDATE);

    -- Update master order status to reflect shipment
    UPDATE orders
    SET status = 'SHIPPED'
    WHERE order_id = v_order_id;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(
        'TRANSACTION 4 SUCCESS | order_id=' || v_order_id ||
        ' | SHIPPED via FedEx'
    );

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE(
            'TRANSACTION 4 FAILED | ' || SQLERRM
        );
END;
/

-- ============================================================
-- SECTION 3: CONSTRAINT & FK VIOLATION TESTING
-- ============================================================

-- ------------------------------------------------------------
-- 3.1 FK Violation: Order referencing a non-existent user
-- Expected: ORA-02291 integrity constraint violated
-- INTENTIONALLY COMMENTED OUT
-- ------------------------------------------------------------
/*
INSERT INTO orders (order_id, user_id, order_date, total_amount, status)
VALUES (seq_orders.NEXTVAL, 999999, SYSDATE, 100.00, 'PENDING');

-- ORA-02291: parent key not found
-- user_id=999999 does not exist
*/

-- ------------------------------------------------------------
-- 3.2 FK Violation: Order_Item referencing invalid order
-- ------------------------------------------------------------
/*
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
VALUES (seq_order_items.NEXTVAL, 999999, 1, 1, 99.99);

-- ORA-02291: order_id not found
*/

-- ------------------------------------------------------------
-- 3.3 FK Violation: Order_Item referencing invalid product
-- ------------------------------------------------------------
/*
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
VALUES (seq_order_items.NEXTVAL, 1, 999999, 1, 99.99);

-- ORA-02291: product_id not found
*/

-- ------------------------------------------------------------
-- 3.4 CHECK Constraint Violation: Negative price
-- ------------------------------------------------------------
/*
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
VALUES (seq_order_items.NEXTVAL, 1, 1, 1, -50.00);

-- ORA-02290: price must be >= 0
*/

-- ------------------------------------------------------------
-- 3.5 CHECK Constraint Violation: Quantity = 0
-- ------------------------------------------------------------
/*
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
VALUES (seq_order_items.NEXTVAL, 1, 1, 0, 99.99);

-- ORA-02290: quantity must be > 0
*/

-- ------------------------------------------------------------
-- 3.6 UNIQUE Constraint Violation: Duplicate email
-- ------------------------------------------------------------
/*
INSERT INTO users (user_id, name, email, password, phone, created_at)
VALUES (seq_users.NEXTVAL, 'Test Duplicate', 'ahmed.raza@gmail.com', 'Test@123', '03001111111', SYSDATE);

-- ORA-00001: duplicate email
*/

-- ------------------------------------------------------------
-- 3.7 UNIQUE Constraint Violation: Duplicate wishlist
-- ------------------------------------------------------------
/*
INSERT INTO wishlists (wishlist_id, user_id, product_id, added_at)
VALUES (seq_wishlists.NEXTVAL, 1, 1, SYSDATE);

-- ORA-00001: duplicate wishlist entry
*/

-- ------------------------------------------------------------
-- 3.8 CHECK Constraint Violation: Invalid order status
-- ------------------------------------------------------------
/*
INSERT INTO orders (order_id, user_id, order_date, total_amount, status)
VALUES (seq_orders.NEXTVAL, 1, SYSDATE, 100.00, 'DISPATCHED');

-- ORA-02290: invalid status
*/

-- ------------------------------------------------------------
-- 3.9 CHECK Constraint Violation: Invalid rating
-- ------------------------------------------------------------
/*
INSERT INTO reviews (review_id, user_id, product_id, rating, review_comment, review_date)
VALUES (seq_reviews.NEXTVAL, 1, 1, 6.0, 'Too good!', SYSDATE);

-- ORA-02290: rating must be 1–5
*/

-- ------------------------------------------------------------
-- 3.10 Stock Guard: Negative inventory attempt
-- ------------------------------------------------------------
/*
UPDATE inventory
SET stock_quantity = -1
WHERE product_id = 1;

-- ORA-02290: stock cannot be negative
*/

-- ------------------------------------------------------------
-- 3.11 LIVE VALIDATION: Constraint Check
-- ------------------------------------------------------------
SELECT
    table_name,
    constraint_name,
    constraint_type,
    status,
    validated
FROM user_constraints
WHERE table_name IN (
    'USERS', 'ORDERS', 'ORDER_ITEMS', 'PRODUCTS',
    'INVENTORY', 'PAYMENTS', 'REVIEWS', 'CART_ITEMS', 'WISHLISTS'
)
ORDER BY table_name, constraint_type;


-- ============================================================
-- SECTION 4: BUSINESS INTELLIGENCE JOIN QUERIES
-- ============================================================

-- ------------------------------------------------------------
-- 4.1 Top 10 Highest Spending Users (Lifetime Value)
-- ------------------------------------------------------------
SELECT
    u.user_id,
    u.name                          AS user_name,
    u.email,
    COUNT(DISTINCT o.order_id)      AS total_orders,
    SUM(o.total_amount)             AS lifetime_spend,
    ROUND(AVG(o.total_amount), 2)   AS avg_order_value,
    MAX(o.order_date)               AS last_order_date
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE o.status NOT IN ('CANCELLED', 'RETURNED', 'REFUNDED')
GROUP BY u.user_id, u.name, u.email
ORDER BY lifetime_spend DESC
FETCH FIRST 10 ROWS ONLY;

-- ------------------------------------------------------------
-- 4.2 Most Ordered Products (by quantity sold)
-- ------------------------------------------------------------
SELECT
    p.product_id,
    p.name                          AS product_name,
    c.category_name,
    p.price                         AS unit_price,
    COUNT(DISTINCT oi.order_id)     AS times_ordered,
    SUM(oi.quantity)                AS total_units_sold,
    SUM(oi.quantity * oi.price)     AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
JOIN categories c ON p.category_id = c.category_id
WHERE o.status NOT IN ('CANCELLED', 'RETURNED', 'REFUNDED')
GROUP BY p.product_id, p.name, c.category_name, p.price
ORDER BY total_units_sold DESC
FETCH FIRST 15 ROWS ONLY;

-- ------------------------------------------------------------
-- 4.3 Revenue by Category
-- ------------------------------------------------------------
SELECT
    c.category_id,
    c.category_name,
    COUNT(DISTINCT p.product_id)    AS total_products,
    COUNT(DISTINCT oi.order_id)     AS total_orders,
    SUM(oi.quantity)                AS units_sold,
    SUM(oi.quantity * oi.price)     AS total_revenue,
    ROUND(AVG(oi.price), 2)         AS avg_product_price
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status NOT IN ('CANCELLED', 'RETURNED', 'REFUNDED')
GROUP BY c.category_id, c.category_name
ORDER BY total_revenue DESC;

-- ------------------------------------------------------------
-- 4.4 Users with Empty Cart (no active cart items)
-- ------------------------------------------------------------
SELECT
    u.user_id,
    u.name          AS user_name,
    u.email,
    u.phone,
    u.created_at    AS member_since
FROM users u
LEFT JOIN cart_items ci ON u.user_id = ci.user_id
WHERE ci.cart_item_id IS NULL
ORDER BY u.user_id;

-- ------------------------------------------------------------
-- 4.5 Products Never Ordered (dead stock candidates)
-- ------------------------------------------------------------
SELECT
    p.product_id,
    p.name              AS product_name,
    c.category_name,
    p.price,
    i.stock_quantity    AS current_stock,
    p.created_at        AS listed_since
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN inventory i ON p.product_id = i.product_id
WHERE oi.order_item_id IS NULL
ORDER BY p.product_id;

-- ------------------------------------------------------------
-- 4.6 Wishlist Popularity (Most Wishlisted Products)
-- ------------------------------------------------------------
SELECT
    p.product_id,
    p.name                          AS product_name,
    c.category_name,
    p.price,
    COUNT(w.wishlist_id)            AS wishlist_count,
    i.stock_quantity                AS current_stock
FROM products p
JOIN wishlists w ON p.product_id = w.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN inventory i ON p.product_id = i.product_id
GROUP BY p.product_id, p.name, c.category_name, p.price, i.stock_quantity
ORDER BY wishlist_count DESC
FETCH FIRST 10 ROWS ONLY;

-- ------------------------------------------------------------
-- 4.7 Cart Abandonment Analysis
-- ------------------------------------------------------------
SELECT
    u.user_id,
    u.name                          AS user_name,
    u.email,
    COUNT(ci.cart_item_id)          AS cart_items_count,
    SUM(ci.quantity * p.price)      AS cart_value,
    MAX(o.order_date)               AS last_order_date,
    ROUND(SYSDATE - MAX(o.order_date), 0) AS days_since_last_order
FROM users u
JOIN cart_items ci ON u.user_id = ci.user_id
JOIN products p ON ci.product_id = p.product_id
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.name, u.email
HAVING MAX(o.order_date) < SYSDATE - 30
   OR MAX(o.order_date) IS NULL
ORDER BY cart_value DESC;

-- ------------------------------------------------------------
-- 4.8 Order Status Distribution
-- ------------------------------------------------------------
SELECT
    status,
    COUNT(order_id)                             AS order_count,
    SUM(total_amount)                           AS total_value,
    ROUND(
        COUNT(order_id) * 100.0
        / SUM(COUNT(order_id)) OVER (), 2
    )                                           AS pct_of_orders
FROM orders
GROUP BY status
ORDER BY order_count DESC;

-- ------------------------------------------------------------
-- 4.9 Monthly Revenue Trend
-- ------------------------------------------------------------
SELECT
    TO_CHAR(o.order_date, 'YYYY-MM')        AS year_month,
    COUNT(DISTINCT o.order_id)              AS orders_placed,
    COUNT(DISTINCT o.user_id)              AS unique_customers,
    SUM(o.total_amount)                     AS monthly_revenue,
    ROUND(AVG(o.total_amount), 2)           AS avg_order_value
FROM orders o
WHERE o.status NOT IN ('CANCELLED', 'RETURNED', 'REFUNDED')
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY year_month DESC;

-- ------------------------------------------------------------
-- 4.10 Payment Method Usage Analysis
-- ------------------------------------------------------------
SELECT
    p.payment_method,
    COUNT(p.payment_id)                     AS total_transactions,
    SUM(p.amount)                           AS total_amount_processed,
    ROUND(AVG(p.amount), 2)                 AS avg_transaction_value,
    SUM(CASE WHEN p.payment_status = 'COMPLETED' THEN 1 ELSE 0 END) AS successful,
    SUM(CASE WHEN p.payment_status = 'FAILED' THEN 1 ELSE 0 END) AS failed,
    SUM(CASE WHEN p.payment_status = 'REFUNDED' THEN 1 ELSE 0 END) AS refunded
FROM payments p
GROUP BY p.payment_method
ORDER BY total_transactions DESC;

-- ------------------------------------------------------------
-- 4.11 Courier Performance Summary
-- ------------------------------------------------------------
SELECT
    s.courier_name,
    COUNT(s.shipment_id) AS total_shipments,
    SUM(CASE WHEN s.shipment_status = 'DELIVERED' THEN 1 ELSE 0 END) AS delivered,
    SUM(CASE WHEN s.shipment_status = 'IN_TRANSIT' THEN 1 ELSE 0 END) AS in_transit,
    SUM(CASE WHEN s.shipment_status = 'PENDING' THEN 1 ELSE 0 END) AS pending,
    SUM(CASE WHEN s.shipment_status = 'RETURNED' THEN 1 ELSE 0 END) AS returned,
    SUM(CASE WHEN s.shipment_status = 'FAILED' THEN 1 ELSE 0 END) AS failed,
    ROUND(
        SUM(CASE WHEN s.shipment_status = 'DELIVERED' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(s.shipment_id), 2
    ) AS delivery_success_pct
FROM shipments s
GROUP BY s.courier_name
ORDER BY total_shipments DESC;

-- ------------------------------------------------------------
-- 4.12 Top Reviewed Products
-- ------------------------------------------------------------
SELECT
    p.product_id,
    p.name                          AS product_name,
    c.category_name,
    COUNT(r.review_id)              AS total_reviews,
    ROUND(AVG(r.rating), 2)         AS avg_rating,
    MIN(r.rating)                   AS lowest_rating,
    MAX(r.rating)                   AS highest_rating
FROM products p
JOIN reviews r ON p.product_id = r.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY p.product_id, p.name, c.category_name
HAVING COUNT(r.review_id) >= 1
ORDER BY avg_rating DESC, total_reviews DESC
FETCH FIRST 15 ROWS ONLY;

-- ------------------------------------------------------------
-- 4.13 Products in Wishlist but Out of Stock
-- ------------------------------------------------------------
SELECT
    p.product_id,
    p.name                          AS product_name,
    c.category_name,
    p.price,
    COUNT(w.wishlist_id)            AS wishlist_count,
    i.stock_quantity
FROM products p
JOIN wishlists w ON p.product_id = w.product_id
JOIN inventory i ON p.product_id = i.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE i.stock_quantity = 0
GROUP BY p.product_id, p.name, c.category_name, p.price, i.stock_quantity
ORDER BY wishlist_count DESC;

-- ------------------------------------------------------------
-- 4.14 Customer Order Frequency Segmentation
-- ------------------------------------------------------------
SELECT
    u.user_id,
    u.name                          AS user_name,
    u.email,
    COUNT(o.order_id)               AS order_count,
    SUM(o.total_amount)             AS lifetime_spend,
    ROUND(AVG(o.total_amount), 2)   AS avg_order_value,
    CASE
        WHEN COUNT(o.order_id) >= 5 AND SUM(o.total_amount) >= 1000 THEN 'PLATINUM'
        WHEN COUNT(o.order_id) >= 3 AND SUM(o.total_amount) >= 500  THEN 'GOLD'
        WHEN COUNT(o.order_id) >= 2 THEN 'SILVER'
        ELSE 'BRONZE'
    END AS customer_tier
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE o.status NOT IN ('CANCELLED', 'RETURNED', 'REFUNDED')
GROUP BY u.user_id, u.name, u.email
ORDER BY lifetime_spend DESC;

-- ------------------------------------------------------------
-- 4.15 Users who Wishlisted and Ordered Same Product
-- ------------------------------------------------------------
SELECT
    u.user_id,
    u.name AS user_name,
    p.product_id,
    p.name AS product_name,
    w.added_at AS wishlisted_on,
    o.order_date AS ordered_on,
    ROUND(o.order_date - w.added_at, 0) AS days_to_purchase
FROM users u
JOIN wishlists w ON u.user_id = w.user_id
JOIN orders o ON u.user_id = o.user_id
JOIN order_items oi ON o.order_id = oi.order_id
                   AND w.product_id = oi.product_id
JOIN products p ON w.product_id = p.product_id
WHERE o.order_date >= w.added_at
ORDER BY days_to_purchase ASC;


-- ============================================================
-- SECTION 5: DATA INTEGRITY SUMMARY QUERIES
-- ============================================================

-- ------------------------------------------------------------
-- 5.1 Master Orphan Record Count Report
-- All counts should be 0 in a clean database
-- ------------------------------------------------------------
SELECT *
FROM (
    SELECT 'Addresses without User' AS check_name,
           COUNT(*) AS orphan_count
    FROM addresses a
    LEFT JOIN users u ON a.user_id = u.user_id
    WHERE u.user_id IS NULL

    UNION ALL
    SELECT 'Orders without User', COUNT(*)
    FROM orders o
    LEFT JOIN users u ON o.user_id = u.user_id
    WHERE u.user_id IS NULL

    UNION ALL
    SELECT 'Order_Items without Order', COUNT(*)
    FROM order_items oi
    LEFT JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_id IS NULL

    UNION ALL
    SELECT 'Order_Items without Product', COUNT(*)
    FROM order_items oi
    LEFT JOIN products p ON oi.product_id = p.product_id
    WHERE p.product_id IS NULL

    UNION ALL
    SELECT 'Inventory without Product', COUNT(*)
    FROM inventory i
    LEFT JOIN products p ON i.product_id = p.product_id
    WHERE p.product_id IS NULL

    UNION ALL
    SELECT 'Products without Inventory', COUNT(*)
    FROM products p
    LEFT JOIN inventory i ON p.product_id = i.product_id
    WHERE i.inventory_id IS NULL

    UNION ALL
    SELECT 'Cart_Items without User', COUNT(*)
    FROM cart_items ci
    LEFT JOIN users u ON ci.user_id = u.user_id
    WHERE u.user_id IS NULL

    UNION ALL
    SELECT 'Cart_Items without Product', COUNT(*)
    FROM cart_items ci
    LEFT JOIN products p ON ci.product_id = p.product_id
    WHERE p.product_id IS NULL

    UNION ALL
    SELECT 'Wishlists without User', COUNT(*)
    FROM wishlists w
    LEFT JOIN users u ON w.user_id = u.user_id
    WHERE u.user_id IS NULL

    UNION ALL
    SELECT 'Wishlists without Product', COUNT(*)
    FROM wishlists w
    LEFT JOIN products p ON w.product_id = p.product_id
    WHERE p.product_id IS NULL

    UNION ALL
    SELECT 'Payments without Order', COUNT(*)
    FROM payments py
    LEFT JOIN orders o ON py.order_id = o.order_id
    WHERE o.order_id IS NULL

    UNION ALL
    SELECT 'Shipments without Order', COUNT(*)
    FROM shipments s
    LEFT JOIN orders o ON s.order_id = o.order_id
    WHERE o.order_id IS NULL

    UNION ALL
    SELECT 'Reviews without User', COUNT(*)
    FROM reviews r
    LEFT JOIN users u ON r.user_id = u.user_id
    WHERE u.user_id IS NULL

    UNION ALL
    SELECT 'Reviews without Product', COUNT(*)
    FROM reviews r
    LEFT JOIN products p ON r.product_id = p.product_id
    WHERE p.product_id IS NULL
);

-- ------------------------------------------------------------
-- 5.2 Stock Consistency Check
-- ------------------------------------------------------------
SELECT
    p.product_id,
    p.name AS product_name,
    NVL(i.stock_quantity, -1) AS stock_quantity,
    CASE
        WHEN i.inventory_id IS NULL THEN 'MISSING INVENTORY RECORD'
        WHEN i.stock_quantity < 0 THEN 'NEGATIVE STOCK - DATA ERROR'
        WHEN i.stock_quantity = 0 THEN 'OUT OF STOCK'
        WHEN i.stock_quantity < 10 THEN 'CRITICAL LOW STOCK'
        ELSE 'OK'
    END AS stock_health
FROM products p
LEFT JOIN inventory i ON p.product_id = i.product_id
ORDER BY stock_quantity ASC NULLS FIRST;

-- ------------------------------------------------------------
-- 5.3 Order Total vs Line Items Consistency Check
-- ------------------------------------------------------------
SELECT
    o.order_id,
    o.user_id,
    o.status,
    o.total_amount AS stored_total,
    SUM(oi.quantity * oi.price) AS calculated_total,
    ABS(o.total_amount - SUM(oi.quantity * oi.price)) AS discrepancy
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.user_id, o.status, o.total_amount
HAVING ABS(o.total_amount - SUM(oi.quantity * oi.price)) > 0.01
ORDER BY discrepancy DESC;

-- ------------------------------------------------------------
-- 5.4 Orders without Payment
-- ------------------------------------------------------------
SELECT o.*
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id
WHERE p.payment_id IS NULL;

-- ------------------------------------------------------------
-- 5.5 Orders without Shipment
-- ------------------------------------------------------------
SELECT o.*
FROM orders o
LEFT JOIN shipments s ON o.order_id = s.order_id
WHERE s.shipment_id IS NULL;

-- ------------------------------------------------------------
-- 5.6 Duplicate Email Check
-- ------------------------------------------------------------
SELECT email, COUNT(*) AS duplicate_count
FROM users
GROUP BY email
HAVING COUNT(*) > 1;

-- ------------------------------------------------------------
-- 5.7 Duplicate Inventory Records
-- ------------------------------------------------------------
SELECT product_id, COUNT(*) AS inventory_record_count
FROM inventory
GROUP BY product_id
HAVING COUNT(*) > 1;

-- ------------------------------------------------------------
-- 5.8 Product Image Coverage Check
-- ------------------------------------------------------------
SELECT
    p.product_id,
    p.name AS product_name,
    COUNT(pi.image_id) AS image_count,
    CASE
        WHEN COUNT(pi.image_id) = 0 THEN 'NO IMAGES - CRITICAL'
        WHEN COUNT(pi.image_id) < 3 THEN 'BELOW MINIMUM (3)'
        ELSE 'OK'
    END AS image_status
FROM products p
LEFT JOIN product_images pi ON p.product_id = pi.product_id
GROUP BY p.product_id, p.name
HAVING COUNT(pi.image_id) < 3
ORDER BY image_count ASC;

-- ------------------------------------------------------------
-- 5.9 Full Table Row Count Summary
-- ------------------------------------------------------------
SELECT *
FROM (
    SELECT 'users' AS table_name, COUNT(*) AS row_count FROM users
    UNION ALL SELECT 'addresses', COUNT(*) FROM addresses
    UNION ALL SELECT 'categories', COUNT(*) FROM categories
    UNION ALL SELECT 'products', COUNT(*) FROM products
    UNION ALL SELECT 'product_images', COUNT(*) FROM product_images
    UNION ALL SELECT 'inventory', COUNT(*) FROM inventory
    UNION ALL SELECT 'cart_items', COUNT(*) FROM cart_items
    UNION ALL SELECT 'wishlists', COUNT(*) FROM wishlists
    UNION ALL SELECT 'orders', COUNT(*) FROM orders
    UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
    UNION ALL SELECT 'payments', COUNT(*) FROM payments
    UNION ALL SELECT 'shipments', COUNT(*) FROM shipments
    UNION ALL SELECT 'order_status_history', COUNT(*) FROM order_status_history
    UNION ALL SELECT 'reviews', COUNT(*) FROM reviews
);

-- ------------------------------------------------------------
-- 5.10 Order vs Shipment Mismatch
-- ------------------------------------------------------------
SELECT o.order_id, o.status, s.shipment_status, s.tracking_number
FROM orders o
JOIN shipments s ON o.order_id = s.order_id
WHERE o.status = 'DELIVERED'
AND s.shipment_status != 'DELIVERED';

-- ------------------------------------------------------------
-- 5.11 Payment Mismatch Check
-- ------------------------------------------------------------
SELECT
    o.order_id,
    o.total_amount,
    SUM(p.amount) AS total_paid,
    ABS(o.total_amount - SUM(p.amount)) AS payment_gap
FROM orders o
JOIN payments p ON o.order_id = p.order_id
WHERE p.payment_status = 'COMPLETED'
GROUP BY o.order_id, o.total_amount
HAVING ABS(o.total_amount - SUM(p.amount)) > 0.01;