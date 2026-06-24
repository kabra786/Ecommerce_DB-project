# test_analytics.py

from modules import analytics
from db_connection import get_connection

# -------------------------------------------------------------------
# CONNECT DATABASE
# -------------------------------------------------------------------

try:
    conn = get_connection()
    print("✅ Connected to Oracle Database successfully!")
except Exception as e:
    print(f"❌ Connection failed: {e}")
    exit()


# -------------------------------------------------------------------
# 1. TOTAL SALES
# -------------------------------------------------------------------

print("\n================ TOTAL SALES ================\n")
print(analytics.total_sales(conn))


# -------------------------------------------------------------------
# 2. TOTAL ORDERS
# -------------------------------------------------------------------

print("\n================ TOTAL ORDERS ================\n")
print(analytics.total_orders(conn))


# -------------------------------------------------------------------
# 3. BEST SELLING PRODUCTS
# -------------------------------------------------------------------

print("\n================ BEST SELLING PRODUCTS ================\n")
best = analytics.best_selling_products(conn, 5)

for item in best:
    print(item)


# -------------------------------------------------------------------
# 4. REVENUE BY CATEGORY
# -------------------------------------------------------------------

print("\n================ REVENUE BY CATEGORY ================\n")
category_revenue = analytics.revenue_by_category(conn)

for item in category_revenue:
    print(item)


# -------------------------------------------------------------------
# 5. LOW STOCK PRODUCTS
# -------------------------------------------------------------------

print("\n================ LOW STOCK PRODUCTS ================\n")
low_stock = analytics.low_stock_products(conn, 200)

for item in low_stock:
    print(item)


# -------------------------------------------------------------------
# 6. USER PURCHASE SUMMARY
# -------------------------------------------------------------------

print("\n================ USER PURCHASE SUMMARY ================\n")
user_id = 1
print(analytics.user_purchase_summary(conn, user_id))


# -------------------------------------------------------------------
# 7. CART ANALYSIS
# -------------------------------------------------------------------

print("\n================ CART ANALYSIS ================\n")
print(analytics.cart_analysis(conn))


# -------------------------------------------------------------------
# 8. PRODUCT RATING SUMMARY
# -------------------------------------------------------------------

print("\n================ PRODUCT RATING SUMMARY ================\n")
ratings = analytics.product_rating_summary(conn)

for item in ratings:
    print(item)


# -------------------------------------------------------------------
# 9. DASHBOARD SUMMARY
# -------------------------------------------------------------------

print("\n================ DASHBOARD SUMMARY ================\n")
print(analytics.dashboard_summary(conn))


# -------------------------------------------------------------------
# CLOSE CONNECTION
# -------------------------------------------------------------------

try:
    conn.close()
    print("\n✅ Oracle connection closed successfully!")
except Exception as e:
    print(f"\n❌ Error closing connection: {e}")