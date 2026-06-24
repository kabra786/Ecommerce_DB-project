# analytics.py
# Production-ready Oracle analytics / BI module for E-Commerce system
# Uses raw SQL with oracledb (cx_Oracle compatible) — NO ORM

try:
    import oracledb as cx_Oracle
except ImportError:
    import cx_Oracle

from typing import List, Optional, Dict


# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

def _dict_from_row(cursor, row) -> Dict:
    """Convert a single row to dictionary"""
    if not row:
        return {}

    if not cursor.description:
        return {}

    columns = [col[0].lower() for col in cursor.description]
    return dict(zip(columns, row))


def _dicts_from_rows(cursor) -> List[Dict]:
    """Convert multiple rows to list of dictionaries"""
    if not cursor.description:
        return []

    columns = [col[0].lower() for col in cursor.description]
    rows = cursor.fetchall()
    return [dict(zip(columns, row)) for row in rows]


# ---------------------------------------------------------------------------
# 1. total_sales
# ---------------------------------------------------------------------------

def total_sales(conn) -> Dict:
    cursor = None
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT NVL(SUM(total_amount), 0) AS total_revenue
            FROM orders
        """)

        value = cursor.fetchone()[0]
        return {"total_revenue": value}

    except Exception as e:
        print(f"[total_sales] Error: {e}")
        return {"total_revenue": 0}

    finally:
        if cursor:
            cursor.close()


# ---------------------------------------------------------------------------
# 2. total_orders
# ---------------------------------------------------------------------------

def total_orders(conn) -> Dict:
    cursor = None
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT COUNT(*) AS total_orders
            FROM orders
        """)

        value = cursor.fetchone()[0]
        return {"total_orders": value}

    except Exception as e:
        print(f"[total_orders] Error: {e}")
        return {"total_orders": 0}

    finally:
        if cursor:
            cursor.close()


# ---------------------------------------------------------------------------
# 3. best_selling_products
# ---------------------------------------------------------------------------

def best_selling_products(conn, limit: int = 5) -> List[Dict]:
    cursor = None
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT *
            FROM (
                SELECT
                    oi.product_id,
                    p.name AS product_name,
                    SUM(oi.quantity) AS total_quantity_sold
                FROM order_items oi
                JOIN products p ON p.product_id = oi.product_id
                GROUP BY oi.product_id, p.name
                ORDER BY total_quantity_sold DESC
            )
            WHERE ROWNUM <= :limit
        """, {"limit": limit})

        return _dicts_from_rows(cursor)

    except Exception as e:
        print(f"[best_selling_products] Error: {e}")
        return []

    finally:
        if cursor:
            cursor.close()


# ---------------------------------------------------------------------------
# 4. revenue_by_category
# ---------------------------------------------------------------------------

def revenue_by_category(conn) -> List[Dict]:
    cursor = None
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT
                c.category_name,
                NVL(SUM(oi.quantity * oi.price), 0) AS total_revenue
            FROM order_items oi
            JOIN products p ON p.product_id = oi.product_id
            JOIN categories c ON c.category_id = p.category_id
            GROUP BY c.category_name
            ORDER BY total_revenue DESC
        """)

        return _dicts_from_rows(cursor)

    except Exception as e:
        print(f"[revenue_by_category] Error: {e}")
        return []

    finally:
        if cursor:
            cursor.close()


# ---------------------------------------------------------------------------
# 5. low_stock_products
# ---------------------------------------------------------------------------

def low_stock_products(conn, threshold: int) -> List[Dict]:
    cursor = None
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT
                p.product_id,
                p.name AS product_name,
                i.stock_quantity
            FROM inventory i
            JOIN products p ON p.product_id = i.product_id
            WHERE i.stock_quantity < :threshold
            ORDER BY i.stock_quantity ASC
        """, {"threshold": threshold})

        return _dicts_from_rows(cursor)

    except Exception as e:
        print(f"[low_stock_products] Error: {e}")
        return []

    finally:
        if cursor:
            cursor.close()


# ---------------------------------------------------------------------------
# 6. user_purchase_summary
# ---------------------------------------------------------------------------

def user_purchase_summary(conn, user_id: int) -> Dict:
    cursor = None
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT
                COUNT(*) AS total_orders,
                NVL(SUM(total_amount), 0) AS total_spent,
                MAX(order_date) AS last_order_date
            FROM orders
            WHERE user_id = :user_id
        """, {"user_id": user_id})

        row = cursor.fetchone()
        return _dict_from_row(cursor, row)

    except Exception as e:
        print(f"[user_purchase_summary] Error: {e}")
        return {
            "total_orders": 0,
            "total_spent": 0,
            "last_order_date": None
        }

    finally:
        if cursor:
            cursor.close()


# ---------------------------------------------------------------------------
# 7. cart_analysis
# ---------------------------------------------------------------------------

def cart_analysis(conn, limit: int = 5) -> Dict:
    cursor = None
    try:
        cursor = conn.cursor()

        # totals
        cursor.execute("""
            SELECT
                COUNT(*) AS total_rows,
                NVL(SUM(quantity), 0) AS total_items
            FROM cart_items
        """)

        row = cursor.fetchone()

        total_items = row[1] if row else 0

        # most added products
        cursor.execute("""
            SELECT *
            FROM (
                SELECT
                    ci.product_id,
                    p.name AS product_name,
                    COUNT(*) AS times_added,
                    SUM(ci.quantity) AS total_quantity
                FROM cart_items ci
                JOIN products p ON p.product_id = ci.product_id
                GROUP BY ci.product_id, p.name
                ORDER BY times_added DESC
            )
            WHERE ROWNUM <= :limit
        """, {"limit": limit})

        most_added = _dicts_from_rows(cursor)

        return {
            "total_items_in_carts": total_items,
            "most_added_products": most_added
        }

    except Exception as e:
        print(f"[cart_analysis] Error: {e}")
        return {
            "total_items_in_carts": 0,
            "most_added_products": []
        }

    finally:
        if cursor:
            cursor.close()


# ---------------------------------------------------------------------------
# 8. product_rating_summary
# ---------------------------------------------------------------------------

def product_rating_summary(conn) -> List[Dict]:
    cursor = None
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT
                r.product_id,
                p.name AS product_name,
                ROUND(AVG(r.rating), 2) AS avg_rating,
                COUNT(*) AS total_reviews
            FROM reviews r
            JOIN products p ON p.product_id = r.product_id
            GROUP BY r.product_id, p.name
            ORDER BY avg_rating DESC
        """)

        return _dicts_from_rows(cursor)

    except Exception as e:
        print(f"[product_rating_summary] Error: {e}")
        return []

    finally:
        if cursor:
            cursor.close()


# ---------------------------------------------------------------------------
# 9. dashboard_summary
# ---------------------------------------------------------------------------

def dashboard_summary(conn) -> Dict:
    cursor = None
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT
                (SELECT COUNT(*) FROM users) AS total_users,
                (SELECT COUNT(*) FROM products) AS total_products,
                (SELECT COUNT(*) FROM orders) AS total_orders,
                (SELECT NVL(SUM(total_amount), 0) FROM orders) AS total_revenue,
                (SELECT COUNT(*) FROM inventory WHERE stock_quantity < 5) AS low_stock_count
            FROM dual
        """)

        row = cursor.fetchone()
        return _dict_from_row(cursor, row)

    except Exception as e:
        print(f"[dashboard_summary] Error: {e}")
        return {
            "total_users": 0,
            "total_products": 0,
            "total_orders": 0,
            "total_revenue": 0,
            "low_stock_count": 0
        }

    finally:
        if cursor:
            cursor.close()
            