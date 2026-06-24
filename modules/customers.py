# ============================================================
# modules/customers.py
# Oracle XE - E-Commerce Customer Module (FINAL FIXED)
# ============================================================

from db_connection import get_connection


# ============================================================
# Helper Functions
# ============================================================

def _rows_to_dicts(cursor):
    columns = [col[0].lower() for col in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def _row_to_dict(cursor, row):
    if not row:
        return None
    columns = [col[0].lower() for col in cursor.description]
    return dict(zip(columns, row))


# ============================================================
# 1. Get All Customers
# ============================================================
def get_all_customers(conn):
    cursor = None

    try:
        cursor = conn.cursor()

        query = """
        SELECT 
            u.user_id,
            u.name,
            u.email,
            u.phone,
            u.created_at,

            NVL(COUNT(DISTINCT o.order_id), 0) AS total_orders,

            NVL(SUM(o.total_amount), 0) AS total_spent,

            (
                SELECT COUNT(*)
                FROM wishlists w
                WHERE w.user_id = u.user_id
            ) AS wishlist_count,

            (
                SELECT COUNT(*)
                FROM cart_items c
                WHERE c.user_id = u.user_id
            ) AS cart_items_count

        FROM users u

        LEFT JOIN orders o
            ON u.user_id = o.user_id

        GROUP BY
            u.user_id,
            u.name,
            u.email,
            u.phone,
            u.created_at

        ORDER BY u.user_id
        """

        cursor.execute(query)

        return _rows_to_dicts(cursor)

    except Exception as e:
        return {"error": str(e)}

    finally:
        if cursor:
            cursor.close()

# ============================================================
# 2. Get Customer By ID (FIXED ORDER DATE ISSUE)
# ============================================================

def get_customer_by_id(conn, user_id):
    cursor = None

    try:
        cursor = conn.cursor()

        # User info
        cursor.execute(
            "SELECT * FROM users WHERE user_id = :uid",
            {"uid": user_id}
        )

        user_row = cursor.fetchone()

        if not user_row:
            return {"error": "Customer not found"}

        user = _row_to_dict(cursor, user_row)

        # Addresses
        cursor.execute("""
            SELECT *
            FROM addresses
            WHERE user_id = :uid
        """, {"uid": user_id})

        addresses = _rows_to_dicts(cursor)

        # Recent orders
        cursor.execute("""
            SELECT * FROM (
                SELECT *
                FROM orders
                WHERE user_id = :uid
                ORDER BY order_date DESC
            )
            WHERE ROWNUM <= 5
        """, {"uid": user_id})

        recent_orders = _rows_to_dicts(cursor)

        # Wishlist summary
        cursor.execute("""
            SELECT COUNT(*) AS wishlist_count
            FROM wishlists
            WHERE user_id = :uid
        """, {"uid": user_id})

        wishlist_summary = _row_to_dict(cursor, cursor.fetchone())

        return {
            "user": user,
            "addresses": addresses,
            "recent_orders": recent_orders,
            "wishlist_summary": wishlist_summary
        }

    except Exception as e:
        return {"error": str(e)}

    finally:
        if cursor:
            cursor.close()
# ============================================================
# 3. Add Customer
# ============================================================

def add_customer(name, email, password, phone):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT user_id FROM users WHERE email = :email", {"email": email})
        if cursor.fetchone():
            return False, "Email already exists"

        cursor.execute("SELECT USERS_SEQ.NEXTVAL FROM DUAL")
        new_id = cursor.fetchone()[0]

        cursor.execute("""
            INSERT INTO users (user_id, name, email, password, phone, created_at)
            VALUES (:id, :name, :email, :password, :phone, SYSDATE)
        """, {
            "id": new_id,
            "name": name,
            "email": email,
            "password": password,
            "phone": phone
        })

        conn.commit()
        return True, new_id

    except Exception as e:
        if conn:
            conn.rollback()
        return False, str(e)

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


# ============================================================
# 4. Update Customer
# ============================================================

def update_customer(user_id, name=None, email=None, phone=None):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        if email:
            cursor.execute("""
                SELECT user_id FROM users
                WHERE email = :email AND user_id != :id
            """, {"email": email, "id": user_id})

            if cursor.fetchone():
                return False, "Email already in use"

        fields = []
        params = {"id": user_id}

        if name:
            fields.append("name = :name")
            params["name"] = name
        if email:
            fields.append("email = :email")
            params["email"] = email
        if phone:
            fields.append("phone = :phone")
            params["phone"] = phone

        if not fields:
            return False, "No fields to update"

        query = f"UPDATE users SET {', '.join(fields)} WHERE user_id = :id"
        cursor.execute(query, params)

        conn.commit()
        return True, "Customer updated successfully"

    except Exception as e:
        if conn:
            conn.rollback()
        return False, str(e)

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


# ============================================================
# 5. Delete Customer
# ============================================================

def delete_customer(user_id):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT COUNT(*) FROM orders WHERE user_id = :id", {"id": user_id})
        if cursor.fetchone()[0] > 0:
            return False, "Cannot delete customer with orders"

        cursor.execute("DELETE FROM wishlists WHERE user_id = :id", {"id": user_id})
        cursor.execute("DELETE FROM cart_items WHERE user_id = :id", {"id": user_id})
        cursor.execute("DELETE FROM addresses WHERE user_id = :id", {"id": user_id})
        cursor.execute("DELETE FROM users WHERE user_id = :id", {"id": user_id})

        conn.commit()
        return True, "Customer deleted successfully"

    except Exception as e:
        if conn:
            conn.rollback()
        return False, str(e)

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


# ============================================================
# 6. Search Customers
# ============================================================

def search_customers(keyword):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT * FROM users
            WHERE LOWER(name) LIKE LOWER(:kw)
               OR LOWER(email) LIKE LOWER(:kw)
               OR phone LIKE :kw
        """, {"kw": f"%{keyword}%"})

        return _rows_to_dicts(cursor)

    except Exception as e:
        return {"error": str(e)}

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


# ============================================================
# 7. Customer Orders (FIXED)
# ============================================================

def get_customer_orders(user_id):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT * FROM orders
            WHERE user_id = :id
            ORDER BY order_date DESC
        """, {"id": user_id})

        return _rows_to_dicts(cursor)

    except Exception as e:
        return {"error": str(e)}

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


# ============================================================
# 8. Top Customers
# ============================================================

def get_top_customers(limit=10):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT u.user_id, u.name, NVL(SUM(o.total_amount),0) AS total_spent
            FROM users u
            LEFT JOIN orders o ON u.user_id = o.user_id
            GROUP BY u.user_id, u.name
            ORDER BY total_spent DESC
            FETCH FIRST :lim ROWS ONLY
        """, {"lim": limit})

        return _rows_to_dicts(cursor)

    except Exception as e:
        return {"error": str(e)}

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


# ============================================================
# 9. Customer Stats
# ============================================================

def get_customer_stats():
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        stats = {}

        cursor.execute("SELECT COUNT(*) FROM users")
        stats["total_customers"] = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(DISTINCT user_id) FROM orders")
        stats["active_customers"] = cursor.fetchone()[0]

        cursor.execute("""
            SELECT COUNT(*) FROM users
            WHERE user_id IN (SELECT DISTINCT user_id FROM orders)
        """)
        stats["customers_with_orders"] = cursor.fetchone()[0]

        cursor.execute("""
            SELECT COUNT(*) FROM users
            WHERE user_id NOT IN (SELECT DISTINCT user_id FROM orders)
        """)
        stats["customers_without_orders"] = cursor.fetchone()[0]

        cursor.execute("""
            SELECT NVL(AVG(total_spent),0)
            FROM (
                SELECT SUM(total_amount) total_spent
                FROM orders
                GROUP BY user_id
            )
        """)
        stats["average_spending"] = cursor.fetchone()[0]

        return stats

    except Exception as e:
        return {"error": str(e)}

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


# ============================================================
# 10. Addresses
# ============================================================

def get_customer_addresses(user_id):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM addresses WHERE user_id = :id", {"id": user_id})
        return _rows_to_dicts(cursor)

    except Exception as e:
        return {"error": str(e)}

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


def add_customer_address(user_id, address_line, city, state, postal_code, country):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO addresses (address_id, user_id, address_line, city, state, postal_code, country)
            VALUES (ADDRESSES_SEQ.NEXTVAL, :user_id, :addr, :city, :state, :postal, :country)
        """, {
            "user_id": user_id,
            "addr": address_line,
            "city": city,
            "state": state,
            "postal": postal_code,
            "country": country
        })

        conn.commit()
        return True, "Address added"

    except Exception as e:
        if conn:
            conn.rollback()
        return False, str(e)

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


def update_customer_address(address_id, address_line=None, city=None, state=None, postal_code=None, country=None):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        fields = []
        params = {"id": address_id}

        if address_line:
            fields.append("address_line = :address_line")
            params["address_line"] = address_line
        if city:
            fields.append("city = :city")
            params["city"] = city
        if state:
            fields.append("state = :state")
            params["state"] = state
        if postal_code:
            fields.append("postal_code = :postal_code")
            params["postal_code"] = postal_code
        if country:
            fields.append("country = :country")
            params["country"] = country

        if not fields:
            return False, "No update fields"

        query = f"UPDATE addresses SET {', '.join(fields)} WHERE address_id = :id"
        cursor.execute(query, params)

        conn.commit()
        return True, "Address updated"

    except Exception as e:
        if conn:
            conn.rollback()
        return False, str(e)

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


def delete_customer_address(address_id):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("DELETE FROM addresses WHERE address_id = :id", {"id": address_id})

        conn.commit()
        return True, "Address deleted"

    except Exception as e:
        if conn:
            conn.rollback()
        return False, str(e)

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


# ============================================================
# Wishlist
# ============================================================

def get_customer_wishlist(user_id):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM wishlists WHERE user_id = :id", {"id": user_id})
        return _rows_to_dicts(cursor)

    except Exception as e:
        return {"error": str(e)}

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


# ============================================================
# Cart
# ============================================================

def get_customer_cart(user_id):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM cart_items WHERE user_id = :id", {"id": user_id})
        return _rows_to_dicts(cursor)

    except Exception as e:
        return {"error": str(e)}

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()