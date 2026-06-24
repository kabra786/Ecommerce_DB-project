from modules.orders import *

print("===== TESTING ORDERS MODULE =====")

# ------------------------------------------------
# TEST 1 → GET ALL ORDERS
# ------------------------------------------------
orders = get_all_orders()

print("\nALL ORDERS:")
print(orders[:2])   # show first 2 orders


# ------------------------------------------------
# TEST 2 → GET ORDER BY ID
# ------------------------------------------------
print("\nORDER DETAILS:")
print(get_order_by_id(1))


# ------------------------------------------------
# TEST 3 → ORDER STATS
# ------------------------------------------------
print("\nORDER STATS:")
print(get_order_stats())


# ------------------------------------------------
# TEST 4 → SEARCH ORDERS
# ------------------------------------------------
print("\nSEARCH RESULTS:")
print(search_orders("PENDING"))


# ------------------------------------------------
# TEST 5 → RECENT ORDERS
# ------------------------------------------------
print("\nRECENT ORDERS:")
print(get_recent_orders(5))