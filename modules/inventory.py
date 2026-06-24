# inventory.py
# Production-ready Oracle inventory module for E-Commerce system
# Uses raw SQL with oracledb (cx_Oracle compatible) — NO ORM

try:
    import oracledb as cx_Oracle
except ImportError:
    import cx_Oracle

from typing import List, Optional, Tuple
import logging


# ---------------------------------------------------------------------------
# Logging Configuration
# ---------------------------------------------------------------------------

logging.basicConfig(
    level=logging.ERROR,
    format="%(asctime)s - %(levelname)s - %(message)s"
)


# ---------------------------------------------------------------------------
# Helper: Convert rows to dicts (FIXED DUPLICATION SAFE)
# ---------------------------------------------------------------------------

def _rows_to_dicts(cursor):
    if not cursor.description:
        return []

    columns = [col[0].lower() for col in cursor.description]
    rows = cursor.fetchall()
    return [dict(zip(columns, row)) for row in rows]


# ---------------------------------------------------------------------------
# 1. get_all_inventory
# ---------------------------------------------------------------------------

def get_all_inventory(conn) -> List[dict]:
    cursor = None

    try:
        cursor = conn.cursor()

        cursor.execute("""
            SELECT
                inventory_id,
                product_id,
                stock_quantity,
                last_updated
            FROM inventory
            ORDER BY inventory_id
        """)

        return _rows_to_dicts(cursor)

    except Exception as e:
        logging.error(f"[get_all_inventory] Error: {e}")
        return []

    finally:
        if cursor:
            cursor.close()


# ---------------------------------------------------------------------------
# 2. get_inventory_by_product_id
# ---------------------------------------------------------------------------

def get_inventory_by_product_id(conn, product_id: int) -> Optional[dict]:
    cursor = None

    try:
        cursor = conn.cursor()

        cursor.execute("""
            SELECT
                inventory_id,
                product_id,
                stock_quantity,
                last_updated
            FROM inventory
            WHERE product_id = :product_id
        """, {"product_id": product_id})

        row = cursor.fetchone()

        if not row:
            return None

        columns = [col[0].lower() for col in cursor.description]
        return dict(zip(columns, row))

    except Exception as e:
        logging.error(f"[get_inventory_by_product_id] Error: {e}")
        return None

    finally:
        if cursor:
            cursor.close()


# ---------------------------------------------------------------------------
# 3. add_inventory
# ---------------------------------------------------------------------------

def add_inventory(conn, product_id: int, stock_quantity: int) -> Tuple[bool, str]:

    if stock_quantity < 0:
        return False, "Stock cannot be negative"

    cursor = None

    try:
        cursor = conn.cursor()

        cursor.execute("""
            SELECT COUNT(*)
            FROM inventory
            WHERE product_id = :product_id
        """, {"product_id": product_id})

        if cursor.fetchone()[0] > 0:
            return False, "Inventory already exists"

        cursor.execute("""
            INSERT INTO inventory (
                inventory_id,
                product_id,
                stock_quantity,
                last_updated
            )
            VALUES (
                (SELECT NVL(MAX(inventory_id), 0) + 1 FROM inventory),
                :product_id,
                :stock_quantity,
                SYSDATE
            )
        """, {
            "product_id": product_id,
            "stock_quantity": stock_quantity
        })

        conn.commit()
        return True, "Inventory added successfully"

    except Exception as e:
        conn.rollback()
        return False, str(e)

    finally:
        if cursor:
            cursor.close()


# ---------------------------------------------------------------------------
# 4. update_stock
# ---------------------------------------------------------------------------

def update_stock(conn, product_id: int, stock_quantity: int) -> Tuple[bool, str]:

    if stock_quantity < 0:
        return False, "Stock cannot be negative"

    cursor = None

    try:
        cursor = conn.cursor()

        cursor.execute("""
            UPDATE inventory
            SET stock_quantity = :stock_quantity,
                last_updated = SYSDATE
            WHERE product_id = :product_id
        """, {
            "stock_quantity": stock_quantity,
            "product_id": product_id
        })

        if cursor.rowcount == 0:
            conn.rollback()
            return False, "Product not found in inventory"

        conn.commit()
        return True, "Stock updated successfully"

    except Exception as e:
        conn.rollback()
        return False, str(e)

    finally:
        if cursor:
            cursor.close()


# ---------------------------------------------------------------------------
# 5. delete_inventory_by_product
# ---------------------------------------------------------------------------

def delete_inventory_by_product(conn, product_id: int) -> Tuple[bool, str]:

    cursor = None

    try:
        cursor = conn.cursor()

        cursor.execute("""
            DELETE FROM inventory
            WHERE product_id = :product_id
        """, {"product_id": product_id})

        if cursor.rowcount == 0:
            conn.rollback()
            return False, "No record found"

        conn.commit()
        return True, "Deleted successfully"

    except Exception as e:
        conn.rollback()
        return False, str(e)

    finally:
        if cursor:
            cursor.close()


# ---------------------------------------------------------------------------
# 6. low_stock_products
# ---------------------------------------------------------------------------

def low_stock_products(conn, threshold: int) -> List[dict]:

    cursor = None

    try:
        cursor = conn.cursor()

        cursor.execute("""
            SELECT
                i.product_id,
                p.name AS product_name,
                i.stock_quantity
            FROM inventory i
            JOIN products p ON i.product_id = p.product_id
            WHERE i.stock_quantity < :threshold
            ORDER BY i.stock_quantity ASC
        """, {"threshold": threshold})

        return _rows_to_dicts(cursor)

    except Exception as e:
        logging.error(f"[low_stock_products] Error: {e}")
        return []

    finally:
        if cursor:
            cursor.close()


# ---------------------------------------------------------------------------
# 7. inventory_summary
# ---------------------------------------------------------------------------

def inventory_summary(conn) -> Optional[dict]:

    cursor = None

    try:
        cursor = conn.cursor()

        cursor.execute("""
            SELECT
                COUNT(*) AS total_products_in_inventory,
                NVL(SUM(stock_quantity), 0) AS total_stock_items,
                NVL(SUM(CASE WHEN stock_quantity < 5 THEN 1 ELSE 0 END), 0) AS low_stock_count,
                MAX(last_updated) AS last_updated_latest_date
            FROM inventory
        """)

        row = cursor.fetchone()

        if not row:
            return {
                "total_products_in_inventory": 0,
                "total_stock_items": 0,
                "low_stock_count": 0,
                "last_updated_latest_date": None
            }

        columns = [col[0].lower() for col in cursor.description]
        return dict(zip(columns, row))

    except Exception as e:
        logging.error(f"[inventory_summary] Error: {e}")
        return None

    finally:
        if cursor:
            cursor.close()
            