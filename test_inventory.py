# test_inventory.py

from modules import inventory
from db_connection import get_connection


# -------------------------------------------------------------------
# CREATE DATABASE CONNECTION
# -------------------------------------------------------------------

try:
    conn = get_connection()
    print("✅ Connected to Oracle Database successfully!")

except Exception as e:
    print(f"❌ Database connection failed: {e}")
    exit()


# -------------------------------------------------------------------
# TEST 1 — Add Inventory
# -------------------------------------------------------------------

print("\n================ TEST 1: add_inventory ================\n")

result = inventory.add_inventory(conn, 1, 50)

print(result)


# -------------------------------------------------------------------
# TEST 2 — Get All Inventory
# -------------------------------------------------------------------

print("\n================ TEST 2: get_all_inventory ================\n")

all_inventory = inventory.get_all_inventory(conn)

if all_inventory:
    for item in all_inventory:
        print(item)
else:
    print("No inventory records found.")


# -------------------------------------------------------------------
# TEST 3 — Get Inventory By Product ID
# -------------------------------------------------------------------

print("\n================ TEST 3: get_inventory_by_product_id ================\n")

item = inventory.get_inventory_by_product_id(conn, 1)

if item:
    print(item)
else:
    print("Inventory record not found.")


# -------------------------------------------------------------------
# TEST 4 — Update Stock
# -------------------------------------------------------------------

print("\n================ TEST 4: update_stock ================\n")

result = inventory.update_stock(conn, 1, 120)

print(result)


# -------------------------------------------------------------------
# TEST 5 — Low Stock Products
# -------------------------------------------------------------------

print("\n================ TEST 5: low_stock_products ================\n")

low_stock = inventory.low_stock_products(conn, 200)

if low_stock:
    for item in low_stock:
        print(item)
else:
    print("No low stock products found.")


# -------------------------------------------------------------------
# TEST 6 — Inventory Summary
# -------------------------------------------------------------------

print("\n================ TEST 6: inventory_summary ================\n")

summary = inventory.inventory_summary(conn)

if summary:
    print(summary)
else:
    print("Failed to fetch inventory summary.")


# -------------------------------------------------------------------
# TEST 7 — Delete Inventory
# -------------------------------------------------------------------

print("\n================ TEST 7: delete_inventory_by_product ================\n")

result = inventory.delete_inventory_by_product(conn, 1)

print(result)


# -------------------------------------------------------------------
# CLOSE DATABASE CONNECTION
# -------------------------------------------------------------------

try:
    conn.close()
    print("\n✅ Oracle connection closed successfully!")

except Exception as e:
    print(f"\n❌ Error while closing connection: {e}")