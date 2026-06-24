# =============================================================
# modules/products.py
# E-Commerce DB — Product Module (Oracle Backend - FIXED)
# =============================================================

from db_connection import get_connection


# -------------------------------------------------------------
# Helper: Convert rows to dictionaries
# -------------------------------------------------------------
def _rows_to_dicts(cursor):
    columns = [col[0].lower() for col in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


# -------------------------------------------------------------
# 1. Get all products
# -------------------------------------------------------------
def get_all_products(conn):
    cursor = None

    try:
        cursor = conn.cursor()

        cursor.execute("""
            SELECT
                p.product_id,
                p.name AS product_name,
                p.description,
                p.price,
                p.created_at,
                c.category_id,
                c.category_name,
                NVL(i.stock_quantity, 0) AS stock_quantity,
                CASE
                    WHEN NVL(i.stock_quantity, 0) = 0 THEN 'Out of Stock'
                    WHEN NVL(i.stock_quantity, 0) <= 10 THEN 'Critical'
                    WHEN NVL(i.stock_quantity, 0) <= 20 THEN 'Low'
                    WHEN NVL(i.stock_quantity, 0) <= 50 THEN 'Moderate'
                    ELSE 'Healthy'
                END AS stock_status
            FROM products p
            JOIN categories c
                ON p.category_id = c.category_id
            LEFT JOIN inventory i
                ON p.product_id = i.product_id
            ORDER BY p.product_id
        """)

        return _rows_to_dicts(cursor)

    except Exception as e:
        print("[get_all_products] ERROR:", e)
        return []

    finally:
        if cursor:
            cursor.close()


# -------------------------------------------------------------
# 2. Get product by ID
# -------------------------------------------------------------
def get_product_by_id(conn, product_id):
    cursor = None

    try:
        cursor = conn.cursor()

        cursor.execute("""
            SELECT
                p.product_id,
                p.name AS product_name,
                p.description,
                p.price,
                p.created_at,
                c.category_id,
                c.category_name,
                NVL(i.stock_quantity, 0) AS stock_quantity
            FROM products p
            JOIN categories c ON p.category_id = c.category_id
            LEFT JOIN inventory i ON p.product_id = i.product_id
            WHERE p.product_id = :pid
        """, {"pid": product_id})

        row = cursor.fetchone()
        if not row:
            return None

        cols = [c[0].lower() for c in cursor.description]
        return dict(zip(cols, row))

    except Exception as e:
        print("[get_product_by_id] ERROR:", e)
        return None

    finally:
        if cursor:
            cursor.close()


# -------------------------------------------------------------
# 3. Add product (FIXED PARAM ORDER)
# -------------------------------------------------------------
def add_product(conn, name, description, price, category_id, stock_quantity):
    cursor = None
    try:
        cursor = conn.cursor()

        if price < 0 or stock_quantity < 0:
            return False, "Price/Stock cannot be negative"

        cursor.execute(
            "SELECT COUNT(*) FROM categories WHERE category_id = :cid",
            {"cid": category_id}
        )

        if cursor.fetchone()[0] == 0:
            return False, "Invalid category"

        cursor.execute("SELECT seq_products.NEXTVAL FROM dual")
        product_id = cursor.fetchone()[0]

        cursor.execute("""
            INSERT INTO products
            (product_id, category_id, name, description, price, created_at)
            VALUES (:pid, :cid, :name, :desc, :price, SYSDATE)
        """, {
            "pid": product_id,
            "cid": category_id,
            "name": name,
            "desc": description,
            "price": price
        })

        cursor.execute("SELECT seq_inventory.NEXTVAL FROM dual")
        inv_id = cursor.fetchone()[0]

        cursor.execute("""
            INSERT INTO inventory
            (inventory_id, product_id, stock_quantity, last_updated)
            VALUES (:iid, :pid, :qty, SYSDATE)
        """, {
            "iid": inv_id,
            "pid": product_id,
            "qty": stock_quantity
        })

        conn.commit()
        return True, product_id

    except Exception as e:
        conn.rollback()
        return False, str(e)

    finally:
        if cursor:
            cursor.close()


# -------------------------------------------------------------
# 4. Update product
# -------------------------------------------------------------
def update_product(conn, product_id, name=None, price=None, description=None):
    cursor = None

    try:
        cursor = conn.cursor()

        fields = []
        params = {"pid": product_id}

        if name:
            fields.append("name = :name")
            params["name"] = name

        if price is not None:
            if price < 0:
                return False, "Invalid price"
            fields.append("price = :price")
            params["price"] = price

        if description:
            fields.append("description = :desc")
            params["desc"] = description

        if not fields:
            return False, "Nothing to update"

        sql = f"""
            UPDATE products
            SET {', '.join(fields)}
            WHERE product_id = :pid
        """

        cursor.execute(sql, params)
        conn.commit()

        return True, "Updated"

    except Exception as e:
        conn.rollback()
        return False, str(e)

    finally:
        if cursor:
            cursor.close()


# -------------------------------------------------------------
# 5. Delete product
# -------------------------------------------------------------
def delete_product(conn, product_id):
    cursor = None

    try:
        cursor = conn.cursor()

        cursor.execute("DELETE FROM inventory WHERE product_id = :pid", {"pid": product_id})
        cursor.execute("DELETE FROM product_images WHERE product_id = :pid", {"pid": product_id})
        cursor.execute("DELETE FROM reviews WHERE product_id = :pid", {"pid": product_id})
        cursor.execute("DELETE FROM products WHERE product_id = :pid", {"pid": product_id})

        conn.commit()
        return True, "Deleted"

    except Exception as e:
        conn.rollback()
        return False, str(e)

    finally:
        if cursor:
            cursor.close()


# -------------------------------------------------------------
# 6. Search products
# -------------------------------------------------------------
def search_products(conn, keyword):
    cursor = None

    try:
        cursor = conn.cursor()

        kw = f"%{keyword.upper()}%"

        cursor.execute("""
            SELECT p.product_id, p.name AS product_name, p.description, p.price
            FROM products p
            JOIN categories c ON p.category_id = c.category_id
            WHERE UPPER(p.name) LIKE :kw
               OR UPPER(p.description) LIKE :kw
               OR UPPER(c.category_name) LIKE :kw
        """, {"kw": kw})

        return _rows_to_dicts(cursor)

    except Exception as e:
        print("[search_products] ERROR:", e)
        return []

    finally:
        if cursor:
            cursor.close()


# -------------------------------------------------------------
# 7. Get categories
# -------------------------------------------------------------
def get_all_categories(conn):
    cursor = None

    try:
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM categories ORDER BY category_name")
        return _rows_to_dicts(cursor)

    except Exception as e:
        print("[categories] ERROR:", e)
        return []

    finally:
        if cursor:
            cursor.close()