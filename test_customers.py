# =============================================================
# modules/test_customers.py
# Testing Customer Module (Oracle DB)
# =============================================================

from modules.customers import *


# -------------------------------------------------------------
# TEST 1: Get all customers
# -------------------------------------------------------------
print("\n=== ALL CUSTOMERS ===")
customers = get_all_customers()
print(customers)


# -------------------------------------------------------------
# TEST 2: Add a new customer (change values as needed)
# -------------------------------------------------------------
print("\n=== ADD CUSTOMER ===")
result = add_customer(
    name="Test User",
    email="testuser@example.com",
    password="123456",
    phone="03001234567"
)
print(result)


# -------------------------------------------------------------
# TEST 3: Search customer
# -------------------------------------------------------------
print("\n=== SEARCH CUSTOMER ===")
search_result = search_customers("Test")
print(search_result)


# -------------------------------------------------------------
# TEST 4: Get customer by ID (change ID if needed)
# -------------------------------------------------------------
print("\n=== CUSTOMER BY ID ===")
customer = get_customer_by_id(1)   # <-- change ID if needed
print(customer)


# -------------------------------------------------------------
# TEST 5: Update customer (change ID if needed)
# -------------------------------------------------------------
print("\n=== UPDATE CUSTOMER ===")
update_result = update_customer(
    user_id=1,
    name="Updated Name",
    phone="03009876543"
)
print(update_result)


# -------------------------------------------------------------
# TEST 6: Get customer stats
# -------------------------------------------------------------
print("\n=== CUSTOMER STATS ===")
stats = get_customer_stats()
print(stats)


# -------------------------------------------------------------
# TEST 7: Get top customers
# -------------------------------------------------------------
print("\n=== TOP CUSTOMERS ===")
top = get_top_customers(5)
print(top)


# -------------------------------------------------------------
# TEST 8: Customer orders
# -------------------------------------------------------------
print("\n=== CUSTOMER ORDERS ===")
orders = get_customer_orders(1)   # <-- change ID if needed
print(orders)


# -------------------------------------------------------------
# TEST 9: Customer addresses
# -------------------------------------------------------------
print("\n=== CUSTOMER ADDRESSES ===")
addresses = get_customer_addresses(1)
print(addresses)


# -------------------------------------------------------------
# TEST 10: Customer cart
# -------------------------------------------------------------
print("\n=== CUSTOMER CART ===")
cart = get_customer_cart(1)
print(cart)