# =============================================================
# modules/orders.py
# E-Commerce DB — Orders Module (Oracle Backend)
# =============================================================

from db_connection import get_connection


# -------------------------------------------------------------
# HELPER: Convert cursor rows to list of dicts
# -------------------------------------------------------------
def _rows_to_dicts(cursor):
    columns = [col[0].lower() for col in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def _row_to_dict(cursor, row):
    if row is None:
        return None
    columns = [col[0].lower() for col in cursor.description]
    return dict(zip(columns, row))


# -------------------------------------------------------------
# 1. get_all_orders()
# -------------------------------------------------------------
def get_all_orders(conn):
    cursor = None

    try:
        cursor = conn.cursor()

        cursor.execute("""
            SELECT
                o.order_id,
                o.order_date,
                o.total_amount,
                o.status,

                u.user_id,
                u.name AS customer_name,
                u.email AS customer_email,
                u.phone AS customer_phone,

                NVL(p.payment_method, 'N/A') AS payment_method,
                NVL(p.payment_status, 'N/A') AS payment_status,

                NVL(s.shipment_status, 'N/A') AS shipment_status,
                NVL(s.tracking_number, 'N/A') AS tracking_number,
                NVL(s.courier_name, 'N/A') AS courier_name,

                COUNT(oi.order_item_id) AS item_count

            FROM orders o

            JOIN users u
                ON o.user_id = u.user_id

            LEFT JOIN payments p
                ON o.order_id = p.order_id

            LEFT JOIN shipments s
                ON o.order_id = s.order_id

            LEFT JOIN order_items oi
                ON o.order_id = oi.order_id

            GROUP BY
                o.order_id,
                o.order_date,
                o.total_amount,
                o.status,
                u.user_id,
                u.name,
                u.email,
                u.phone,
                p.payment_method,
                p.payment_status,
                s.shipment_status,
                s.tracking_number,
                s.courier_name

            ORDER BY o.order_date DESC
        """)

        return _rows_to_dicts(cursor)

    except Exception as e:
        print(f"[get_all_orders] ERROR: {e}")
        return []

    finally:
        if cursor:
            cursor.close()
# -------------------------------------------------------------
# 2. get_order_by_id(order_id)
# -------------------------------------------------------------
def get_order_by_id(conn, order_id):
    cursor = None

    try:
        cursor = conn.cursor()

        # ----- ORDER HEADER -----
        cursor.execute("""
            SELECT
                o.order_id,
                o.order_date,
                o.total_amount,
                o.status,

                u.user_id,
                u.name AS customer_name,
                u.email AS customer_email,
                u.phone AS customer_phone,

                NVL(p.payment_method, 'N/A') AS payment_method,
                NVL(p.payment_status, 'N/A') AS payment_status,
                NVL(p.amount, 0) AS payment_amount,
                p.payment_date,

                NVL(s.shipment_status, 'N/A') AS shipment_status,
                NVL(s.tracking_number, 'N/A') AS tracking_number,
                NVL(s.courier_name, 'N/A') AS courier_name,
                s.shipped_date,
                s.delivery_date

            FROM orders o

            JOIN users u
                ON o.user_id = u.user_id

            LEFT JOIN payments p
                ON o.order_id = p.order_id

            LEFT JOIN shipments s
                ON o.order_id = s.order_id

            WHERE o.order_id = :oid
        """, {"oid": order_id})

        order = _row_to_dict(cursor, cursor.fetchone())

        if not order:
            return None

        # ----- ORDER ITEMS -----
        cursor.execute("""
            SELECT
                oi.order_item_id,
                oi.quantity,
                oi.price AS unit_price,

                ROUND(oi.quantity * oi.price, 2) AS line_total,

                p.product_id,
                p.name AS product_name,
                p.description,

                c.category_name,

                NVL(i.stock_quantity, 0) AS current_stock

            FROM order_items oi

            JOIN products p
                ON oi.product_id = p.product_id

            JOIN categories c
                ON p.category_id = c.category_id

            LEFT JOIN inventory i
                ON p.product_id = i.product_id

            WHERE oi.order_id = :oid

            ORDER BY oi.order_item_id
        """, {"oid": order_id})

        order["items"] = _rows_to_dicts(cursor)

        # ----- STATUS HISTORY -----
        cursor.execute("""
            SELECT
                status_id,
                status,
                updated_at
            FROM order_status_history
            WHERE order_id = :oid
            ORDER BY updated_at
        """, {"oid": order_id})

        order["status_history"] = _rows_to_dicts(cursor)

        return order

    except Exception as e:
        print(f"[get_order_by_id] ERROR: {e}")
        return None

    finally:
        if cursor:
            cursor.close()

# -------------------------------------------------------------
# 3. create_order(user_id, items_list)
# -------------------------------------------------------------
def create_order(user_id, items_list):
    conn = None
    cursor = None

    try:
        if not items_list:
            return False, "Order must contain at least one item."

        conn = get_connection()
        cursor = conn.cursor()

        # ----- VALIDATE USER -----
        cursor.execute("""
            SELECT COUNT(*)
            FROM users
            WHERE user_id = :uid
        """, {"uid": user_id})

        if cursor.fetchone()[0] == 0:
            return False, f"User ID {user_id} not found."

        total_amount = 0
        validated_items = []

        # ----- VALIDATE PRODUCTS + STOCK -----
        for item in items_list:

            product_id = item.get("product_id")
            quantity = item.get("quantity", 1)

            if not product_id or quantity <= 0:
                return False, "Invalid product or quantity."

            cursor.execute("""
                SELECT
                    p.product_id,
                    p.name,
                    p.price,
                    i.stock_quantity

                FROM products p

                JOIN inventory i
                    ON p.product_id = i.product_id

                WHERE p.product_id = :pid

                FOR UPDATE
            """, {"pid": product_id})

            row = cursor.fetchone()

            if not row:
                return False, f"Product ID {product_id} not found."

            prod_id, prod_name, price, stock = row

            if stock < quantity:
                return (
                    False,
                    f"Insufficient stock for '{prod_name}'. "
                    f"Available={stock}, Requested={quantity}"
                )

            line_total = round(price * quantity, 2)

            total_amount += line_total

            validated_items.append({
                "product_id": prod_id,
                "product_name": prod_name,
                "quantity": quantity,
                "price": price,
                "line_total": line_total
            })

        # ----- CREATE ORDER -----
        cursor.execute("SELECT seq_orders.NEXTVAL FROM dual")
        new_order_id = cursor.fetchone()[0]

        cursor.execute("""
            INSERT INTO orders (
                order_id,
                user_id,
                order_date,
                total_amount,
                status
            )
            VALUES (
                :oid,
                :uid,
                SYSDATE,
                :total,
                'PENDING'
            )
        """, {
            "oid": new_order_id,
            "uid": user_id,
            "total": round(total_amount, 2)
        })

        # ----- INSERT ORDER ITEMS -----
        for item in validated_items:

            cursor.execute("""
                SELECT seq_order_items.NEXTVAL
                FROM dual
            """)

            new_item_id = cursor.fetchone()[0]

            cursor.execute("""
                INSERT INTO order_items (
                    order_item_id,
                    order_id,
                    product_id,
                    quantity,
                    price
                )
                VALUES (
                    :iid,
                    :oid,
                    :pid,
                    :qty,
                    :price
                )
            """, {
                "iid": new_item_id,
                "oid": new_order_id,
                "pid": item["product_id"],
                "qty": item["quantity"],
                "price": item["price"]
            })

            # ----- DEDUCT INVENTORY -----
            cursor.execute("""
                UPDATE inventory
                SET
                    stock_quantity = stock_quantity - :qty,
                    last_updated = SYSDATE
                WHERE product_id = :pid
            """, {
                "qty": item["quantity"],
                "pid": item["product_id"]
            })

        # ----- STATUS HISTORY -----
        cursor.execute("""
            SELECT seq_status_history.NEXTVAL
            FROM dual
        """)

        status_id = cursor.fetchone()[0]

        cursor.execute("""
            INSERT INTO order_status_history (
                status_id,
                order_id,
                status,
                updated_at
            )
            VALUES (
                :sid,
                :oid,
                'PENDING',
                SYSDATE
            )
        """, {
            "sid": status_id,
            "oid": new_order_id
        })

        conn.commit()

        print(f"[create_order] Order #{new_order_id} created successfully.")

        return True, new_order_id

    except Exception as e:

        if conn:
            conn.rollback()

        print(f"[create_order] ERROR: {e}")

        return False, str(e)

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# -------------------------------------------------------------
# 4. update_order_status(order_id, new_status)
# -------------------------------------------------------------
def update_order_status(order_id, new_status):

    VALID_STATUSES = {
        "PENDING",
        "CONFIRMED",
        "PROCESSING",
        "SHIPPED",
        "DELIVERED",
        "CANCELLED",
        "RETURNED",
        "REFUNDED"
    }

    conn = None
    cursor = None

    try:

        new_status = new_status.upper().strip()

        if new_status not in VALID_STATUSES:
            return False, "Invalid order status."

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT status
            FROM orders
            WHERE order_id = :oid
            FOR UPDATE
        """, {"oid": order_id})

        row = cursor.fetchone()

        if not row:
            return False, f"Order ID {order_id} not found."

        current_status = row[0]

        cursor.execute("""
            UPDATE orders
            SET status = :status
            WHERE order_id = :oid
        """, {
            "status": new_status,
            "oid": order_id
        })

        # ----- INSERT STATUS HISTORY -----
        cursor.execute("""
            SELECT seq_status_history.NEXTVAL
            FROM dual
        """)

        status_id = cursor.fetchone()[0]

        cursor.execute("""
            INSERT INTO order_status_history (
                status_id,
                order_id,
                status,
                updated_at
            )
            VALUES (
                :sid,
                :oid,
                :status,
                SYSDATE
            )
        """, {
            "sid": status_id,
            "oid": order_id,
            "status": new_status
        })

        conn.commit()

        print(
            f"[update_order_status] "
            f"{current_status} -> {new_status}"
        )

        return True, "Order status updated successfully."

    except Exception as e:

        if conn:
            conn.rollback()

        print(f"[update_order_status] ERROR: {e}")

        return False, str(e)

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# -------------------------------------------------------------
# 5. cancel_order(order_id)
# -------------------------------------------------------------
def cancel_order(order_id):

    conn = None
    cursor = None

    try:

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT status
            FROM orders
            WHERE order_id = :oid
            FOR UPDATE
        """, {"oid": order_id})

        row = cursor.fetchone()

        if not row:
            return False, f"Order ID {order_id} not found."

        current_status = row[0]

        if current_status in (
            "DELIVERED",
            "CANCELLED",
            "RETURNED",
            "REFUNDED"
        ):
            return False, (
                f"Order cannot be cancelled. "
                f"Current status = {current_status}"
            )

        # ----- RESTORE INVENTORY -----
        cursor.execute("""
            SELECT product_id, quantity
            FROM order_items
            WHERE order_id = :oid
        """, {"oid": order_id})

        items = cursor.fetchall()

        for product_id, quantity in items:

            cursor.execute("""
                UPDATE inventory
                SET
                    stock_quantity = stock_quantity + :qty,
                    last_updated = SYSDATE
                WHERE product_id = :pid
            """, {
                "qty": quantity,
                "pid": product_id
            })

        # ----- UPDATE ORDER -----
        cursor.execute("""
            UPDATE orders
            SET status = 'CANCELLED'
            WHERE order_id = :oid
        """, {"oid": order_id})

        # ----- STATUS HISTORY -----
        cursor.execute("""
            SELECT seq_status_history.NEXTVAL
            FROM dual
        """)

        status_id = cursor.fetchone()[0]

        cursor.execute("""
            INSERT INTO order_status_history (
                status_id,
                order_id,
                status,
                updated_at
            )
            VALUES (
                :sid,
                :oid,
                'CANCELLED',
                SYSDATE
            )
        """, {
            "sid": status_id,
            "oid": order_id
        })

        conn.commit()

        print(f"[cancel_order] Order #{order_id} cancelled.")

        return True, "Order cancelled successfully."

    except Exception as e:

        if conn:
            conn.rollback()

        print(f"[cancel_order] ERROR: {e}")

        return False, str(e)

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# -------------------------------------------------------------
# 6. get_user_orders(user_id)
# -------------------------------------------------------------
def get_user_orders(user_id):

    conn = None
    cursor = None

    try:

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT
                order_id,
                order_date,
                total_amount,
                status
            FROM orders
            WHERE user_id = :uid
            ORDER BY order_date DESC
        """, {"uid": user_id})

        return _rows_to_dicts(cursor)

    except Exception as e:

        print(f"[get_user_orders] ERROR: {e}")

        return []

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# -------------------------------------------------------------
# 7. get_order_stats()
# -------------------------------------------------------------
def get_order_stats():

    conn = None
    cursor = None

    try:

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT
                COUNT(*) AS total_orders,

                NVL(SUM(
                    CASE
                        WHEN status NOT IN (
                            'CANCELLED',
                            'RETURNED',
                            'REFUNDED'
                        )
                        THEN total_amount
                    END
                ), 0) AS total_revenue,

                COUNT(
                    CASE
                        WHEN status = 'PENDING'
                        THEN 1
                    END
                ) AS pending_orders,

                COUNT(
                    CASE
                        WHEN status = 'DELIVERED'
                        THEN 1
                    END
                ) AS delivered_orders

            FROM orders
        """)

        row = cursor.fetchone()

        cols = [col[0].lower() for col in cursor.description]

        return dict(zip(cols, row))

    except Exception as e:

        print(f"[get_order_stats] ERROR: {e}")

        return {}

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# -------------------------------------------------------------
# 8. search_orders(keyword)
# -------------------------------------------------------------
def search_orders(keyword):

    conn = None
    cursor = None

    try:

        conn = get_connection()
        cursor = conn.cursor()

        pattern = f"%{keyword.strip().upper()}%"

        cursor.execute("""
            SELECT
                o.order_id,
                o.order_date,
                o.total_amount,
                o.status,

                u.name AS customer_name,

                NVL(s.tracking_number, 'N/A') AS tracking_number

            FROM orders o

            JOIN users u
                ON o.user_id = u.user_id

            LEFT JOIN shipments s
                ON o.order_id = s.order_id

            WHERE
                UPPER(u.name) LIKE :kw
                OR TO_CHAR(o.order_id) LIKE :kw
                OR UPPER(NVL(s.tracking_number, '')) LIKE :kw
                OR UPPER(o.status) LIKE :kw

            ORDER BY o.order_date DESC
        """, {"kw": pattern})

        return _rows_to_dicts(cursor)

    except Exception as e:

        print(f"[search_orders] ERROR: {e}")

        return []

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# -------------------------------------------------------------
# 9. get_recent_orders(limit)
# -------------------------------------------------------------
def get_recent_orders(limit=10):

    conn = None
    cursor = None

    try:

        conn = get_connection()
        cursor = conn.cursor()

        sql = f"""
            SELECT
                o.order_id,
                o.order_date,
                o.total_amount,
                o.status,

                u.name AS customer_name,
                u.email AS customer_email,

                COUNT(oi.order_item_id) AS item_count

            FROM orders o

            JOIN users u
                ON o.user_id = u.user_id

            LEFT JOIN order_items oi
                ON o.order_id = oi.order_id

            GROUP BY
                o.order_id,
                o.order_date,
                o.total_amount,
                o.status,
                u.name,
                u.email

            ORDER BY o.order_date DESC

            FETCH FIRST {int(limit)} ROWS ONLY
        """

        cursor.execute(sql)

        return _rows_to_dicts(cursor)

    except Exception as e:

        print(f"[get_recent_orders] ERROR: {e}")

        return []

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()