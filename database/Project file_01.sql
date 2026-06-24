/* ============================================================
   FULL RESET - E-COMMERCE DATABASE (ALL 14 TABLES)
============================================================ */

/* =========================
   CHILD TABLES FIRST
========================= */

BEGIN EXECUTE IMMEDIATE 'DROP TABLE reviews CASCADE CONSTRAINTS'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TABLE order_status_history CASCADE CONSTRAINTS'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TABLE shipments CASCADE CONSTRAINTS'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TABLE payments CASCADE CONSTRAINTS'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TABLE order_items CASCADE CONSTRAINTS'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TABLE orders CASCADE CONSTRAINTS'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TABLE wishlists CASCADE CONSTRAINTS'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TABLE cart_items CASCADE CONSTRAINTS'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TABLE inventory CASCADE CONSTRAINTS'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TABLE product_images CASCADE CONSTRAINTS'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

/* =========================
   CORE TABLES
========================= */

BEGIN EXECUTE IMMEDIATE 'DROP TABLE products CASCADE CONSTRAINTS'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TABLE categories CASCADE CONSTRAINTS'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TABLE addresses CASCADE CONSTRAINTS'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TABLE users CASCADE CONSTRAINTS'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

/* =========================
   DROP SEQUENCES
========================= */

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_users'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_addresses'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_categories'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_products'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_images'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_inventory'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_cart_items'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_wishlists'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_orders'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_order_items'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_payments'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_shipments'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_status_history'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_reviews'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

-- ============================================================
-- STAGE 0: E-COMMERCE DATABASE SCHEMA
-- SEQUENCES
-- ============================================================

CREATE SEQUENCE seq_users
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_addresses
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_categories
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_products 
START WITH 1 
INCREMENT BY 1 
NOCACHE 
NOCYCLE;

CREATE SEQUENCE seq_images
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_inventory
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_cart_items
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_wishlists
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_orders
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_order_items
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_payments
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_shipments
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_status_history
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_reviews
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;


-- ============================================================
-- TABLE: USERS
-- ============================================================

CREATE TABLE users (
    user_id       NUMBER          NOT NULL,
    name          VARCHAR2(150)   NOT NULL,
    email         VARCHAR2(255)   NOT NULL,
    password      VARCHAR2(255)   NOT NULL,
    phone         VARCHAR2(20),
    created_at    DATE DEFAULT SYSDATE NOT NULL,

    CONSTRAINT pk_users PRIMARY KEY (user_id),
    CONSTRAINT uq_users_email UNIQUE (email)
);


-- ============================================================
-- TABLE: ADDRESSES
-- ============================================================

CREATE TABLE addresses (
    address_id    NUMBER          NOT NULL,
    user_id       NUMBER          NOT NULL,
    city          VARCHAR2(100)   NOT NULL,
    state         VARCHAR2(100),
    country       VARCHAR2(100)   NOT NULL,
    postal_code   VARCHAR2(20)    NOT NULL,
    full_address  VARCHAR2(500)   NOT NULL,

    CONSTRAINT pk_addresses PRIMARY KEY (address_id),
    CONSTRAINT fk_addresses_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE
);


-- ============================================================
-- TABLE: CATEGORIES
-- ============================================================

CREATE TABLE categories (
    category_id     NUMBER          NOT NULL,
    category_name   VARCHAR2(150)   NOT NULL,
    description     VARCHAR2(500),

    CONSTRAINT pk_categories PRIMARY KEY (category_id),
    CONSTRAINT uq_categories_name UNIQUE (category_name)
);


-- ============================================================
-- TABLE: PRODUCTS
-- ============================================================

CREATE TABLE products (
    product_id    NUMBER          NOT NULL,
    category_id   NUMBER          NOT NULL,
    name          VARCHAR2(255)   NOT NULL,
    description   VARCHAR2(2000),
    price         NUMBER(12,2)    NOT NULL,
    created_at    DATE DEFAULT SYSDATE NOT NULL,

    CONSTRAINT pk_products PRIMARY KEY (product_id),

    CONSTRAINT fk_products_category FOREIGN KEY (category_id)
        REFERENCES categories(category_id),

    CONSTRAINT chk_products_price CHECK (price > 0)
);


-- ============================================================
-- TABLE: PRODUCT_IMAGES
-- ============================================================

CREATE TABLE product_images (
    image_id      NUMBER          NOT NULL,
    product_id    NUMBER          NOT NULL,
    image_url     VARCHAR2(1000)  NOT NULL,

    CONSTRAINT pk_product_images PRIMARY KEY (image_id),

    CONSTRAINT fk_product_images_product FOREIGN KEY (product_id)
        REFERENCES products(product_id) ON DELETE CASCADE
);


-- ============================================================
-- TABLE: INVENTORY
-- ============================================================

CREATE TABLE inventory (
    inventory_id      NUMBER    NOT NULL,
    product_id        NUMBER    NOT NULL,
    stock_quantity    NUMBER    DEFAULT 0 NOT NULL,
    last_updated      DATE      DEFAULT SYSDATE NOT NULL,

    CONSTRAINT pk_inventory PRIMARY KEY (inventory_id),

    CONSTRAINT uq_inventory_product UNIQUE (product_id),

    CONSTRAINT fk_inventory_product FOREIGN KEY (product_id)
        REFERENCES products(product_id) ON DELETE CASCADE,

    CONSTRAINT chk_inventory_stock CHECK (stock_quantity >= 0)
);

-- ============================================================
-- TABLE: CART_ITEMS
-- ============================================================

CREATE TABLE cart_items (
    cart_item_id    NUMBER    NOT NULL,
    user_id         NUMBER    NOT NULL,
    product_id      NUMBER    NOT NULL,
    quantity        NUMBER    DEFAULT 1 NOT NULL,
    added_at        DATE DEFAULT SYSDATE NOT NULL,

    CONSTRAINT pk_cart_items PRIMARY KEY (cart_item_id),
    CONSTRAINT uq_cart_user_product UNIQUE (user_id, product_id),

    CONSTRAINT fk_cart_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE,

    CONSTRAINT fk_cart_product FOREIGN KEY (product_id)
        REFERENCES products(product_id) ON DELETE CASCADE,

    CONSTRAINT chk_cart_qty CHECK (quantity > 0)
);


-- ============================================================
-- TABLE: WISHLISTS
-- ============================================================

CREATE TABLE wishlists (
    wishlist_id     NUMBER NOT NULL,
    user_id         NUMBER NOT NULL,
    product_id      NUMBER NOT NULL,
    added_at        DATE DEFAULT SYSDATE NOT NULL,

    CONSTRAINT pk_wishlists PRIMARY KEY (wishlist_id),
    CONSTRAINT uq_wishlist UNIQUE (user_id, product_id),

    CONSTRAINT fk_wishlist_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE,

    CONSTRAINT fk_wishlist_product FOREIGN KEY (product_id)
        REFERENCES products(product_id) ON DELETE CASCADE
);


-- ============================================================
-- TABLE: ORDERS
-- ============================================================

CREATE TABLE orders (
    order_id        NUMBER NOT NULL,
    user_id         NUMBER NOT NULL,
    order_date      DATE DEFAULT SYSDATE NOT NULL,
    total_amount    NUMBER(12,2) NOT NULL,
    status          VARCHAR2(50) DEFAULT 'PENDING' NOT NULL,

    CONSTRAINT pk_orders PRIMARY KEY (order_id),

    CONSTRAINT fk_orders_user FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    CONSTRAINT chk_orders_total CHECK (total_amount >= 0),

    CONSTRAINT chk_orders_status CHECK (
        status IN (
            'PENDING',
            'CONFIRMED',
            'PROCESSING',
            'SHIPPED',
            'DELIVERED',
            'CANCELLED',
            'RETURNED',
            'REFUNDED'
        )
    )
);


-- ============================================================
-- TABLE: ORDER_ITEMS
-- ============================================================

CREATE TABLE order_items (
    order_item_id NUMBER NOT NULL,
    order_id      NUMBER NOT NULL,
    product_id    NUMBER NOT NULL,
    quantity      NUMBER NOT NULL,
    price         NUMBER(12,2) NOT NULL,

    CONSTRAINT pk_order_items PRIMARY KEY (order_item_id),

    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id) ON DELETE CASCADE,

    CONSTRAINT fk_order_items_product FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    CONSTRAINT chk_order_qty CHECK (quantity > 0),
    CONSTRAINT chk_order_price CHECK (price > 0)
);


-- ============================================================
-- TABLE: PAYMENTS
-- ============================================================

CREATE TABLE payments (
    payment_id        NUMBER NOT NULL,
    order_id          NUMBER NOT NULL,
    payment_method    VARCHAR2(50) NOT NULL,
    payment_status    VARCHAR2(50) DEFAULT 'PENDING' NOT NULL,
    payment_date      DATE DEFAULT SYSDATE NOT NULL,
    amount            NUMBER(12,2) NOT NULL,

    CONSTRAINT pk_payments PRIMARY KEY (payment_id),

    CONSTRAINT fk_payments_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id) ON DELETE CASCADE,

    CONSTRAINT chk_payment_method CHECK (
        payment_method IN (
            'CREDIT_CARD',
            'DEBIT_CARD',
            'PAYPAL',
            'BANK_TRANSFER',
            'CASH_ON_DELIVERY'
        )
    ),

    CONSTRAINT chk_payment_status CHECK (
        payment_status IN (
            'PENDING',
            'COMPLETED',
            'FAILED',
            'REFUNDED'
        )
    ),

    CONSTRAINT chk_payment_amount CHECK (amount >= 0)
);


-- ============================================================
-- TABLE: SHIPMENTS
-- ============================================================

CREATE TABLE shipments (
    shipment_id      NUMBER NOT NULL,
    order_id         NUMBER NOT NULL,
    tracking_number  VARCHAR2(100),
    courier_name     VARCHAR2(150),
    shipment_status  VARCHAR2(50) DEFAULT 'PENDING' NOT NULL,
    shipped_date     DATE,
    delivery_date    DATE,

    CONSTRAINT pk_shipments PRIMARY KEY (shipment_id),
    CONSTRAINT uq_shipments_order UNIQUE (order_id),

    CONSTRAINT fk_shipments_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id) ON DELETE CASCADE,

    CONSTRAINT chk_shipment_status CHECK (
        shipment_status IN (
            'PENDING',
            'SHIPPED',
            'IN_TRANSIT',
            'DELIVERED',
            'RETURNED',
            'FAILED'
        )
    )
);


-- ============================================================
-- TABLE: ORDER_STATUS_HISTORY
-- ============================================================

CREATE TABLE order_status_history (
    status_id     NUMBER NOT NULL,
    order_id      NUMBER NOT NULL,
    status        VARCHAR2(50) NOT NULL,
    updated_at    DATE DEFAULT SYSDATE NOT NULL,

    CONSTRAINT pk_status_history PRIMARY KEY (status_id),

    CONSTRAINT fk_status_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id) ON DELETE CASCADE,

    CONSTRAINT chk_status CHECK (
        status IN (
            'PENDING',
            'CONFIRMED',
            'PROCESSING',
            'SHIPPED',
            'DELIVERED',
            'CANCELLED',
            'RETURNED',
            'REFUNDED'
        )
    )
);


-- ============================================================
-- TABLE: REVIEWS
-- ============================================================

CREATE TABLE reviews (
    review_id       NUMBER NOT NULL,
    user_id         NUMBER NOT NULL,
    product_id      NUMBER NOT NULL,
    rating          NUMBER(2,1) NOT NULL,
    review_comment  VARCHAR2(2000),
    review_date     DATE DEFAULT SYSDATE NOT NULL,

    CONSTRAINT pk_reviews PRIMARY KEY (review_id),

    CONSTRAINT uq_reviews_user_product
        UNIQUE (user_id, product_id),

    CONSTRAINT fk_reviews_user_id FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE,

    CONSTRAINT fk_reviews_product_id FOREIGN KEY (product_id)
        REFERENCES products(product_id) ON DELETE CASCADE,

    CONSTRAINT chk_reviews_rating 
        CHECK (rating >= 1 AND rating <= 5)
);


-- ============================================================
-- SHIPMENT STATUS UPDATE (Original Code)
-- ============================================================

ALTER TABLE shipments DROP CONSTRAINT chk_shipment_status;

ALTER TABLE shipments ADD CONSTRAINT chk_shipment_status
CHECK (
    shipment_status IN (
        'PENDING',
        'DISPATCHED',
        'SHIPPED',
        'IN_TRANSIT',
        'OUT_FOR_DELIVERY',
        'DELIVERED',
        'RETURNED',
        'FAILED'
    )
);


-- ============================================================
-- CHECK TABLES
-- ============================================================

SELECT table_name
FROM user_tables
ORDER BY table_name;


-- ============================================================
-- CHECK SHIPMENT CONSTRAINT
-- ============================================================

SELECT constraint_name, status
FROM user_constraints
WHERE table_name = 'SHIPMENTS';