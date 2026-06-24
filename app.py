# app.py
# Production-ready Streamlit E-Commerce Admin Dashboard
# Run with: streamlit run app.py

import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker

from db_connection import get_connection
from modules import products, orders, customers, inventory, analytics

# ─────────────────────────────────────────────
#  PAGE CONFIG
# ─────────────────────────────────────────────
st.set_page_config(
    page_title="E-Commerce Admin Panel",
    page_icon="🛒",
    layout="wide",
    initial_sidebar_state="expanded",
)

# ─────────────────────────────────────────────
#  GLOBAL STYLES
# ─────────────────────────────────────────────
st.markdown(
    """
    <style>
    /* ── Base ── */
    html, body, [class*="css"] {
        font-family: 'Segoe UI', sans-serif;
    }

    /* ── Sidebar ── */
    [data-testid="stSidebar"] {
        background: linear-gradient(180deg, #0f172a 0%, #1e293b 100%);
    }
    [data-testid="stSidebar"] * { color: #e2e8f0 !important; }
    [data-testid="stSidebar"] .stRadio label {
        font-size: 0.95rem;
        padding: 6px 0;
        cursor: pointer;
    }

    /* ── Metric cards ── */
    [data-testid="metric-container"] {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        padding: 16px 20px;
        box-shadow: 0 1px 4px rgba(0,0,0,0.06);
    }
    [data-testid="stMetricValue"] { font-size: 1.9rem !important; font-weight: 700; }
    [data-testid="stMetricLabel"] { font-size: 0.8rem !important; color: #64748b !important; }

    /* ── Section headers ── */
    .section-header {
        font-size: 1.55rem;
        font-weight: 700;
        color: #0f172a;
        margin-bottom: 4px;
    }
    .section-sub {
        font-size: 0.88rem;
        color: #64748b;
        margin-bottom: 20px;
    }
    .divider { border-top: 1px solid #e2e8f0; margin: 24px 0; }

    /* ── Buttons ── */
    .stButton > button {
        border-radius: 8px;
        font-weight: 600;
        transition: all .15s ease;
    }
    .stButton > button:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0,0,0,0.12); }

    /* ── Dataframe ── */
    [data-testid="stDataFrame"] { border-radius: 10px; overflow: hidden; }

    /* ── Form ── */
    [data-testid="stForm"] {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        padding: 20px;
    }

    /* ── Expander ── */
    [data-testid="stExpander"] {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
    }
    </style>
    """,
    unsafe_allow_html=True,
)


# ─────────────────────────────────────────────
#  DB CONNECTION  (cached per session)
# ─────────────────────────────────────────────
@st.cache_resource(show_spinner="Connecting to Oracle database…")
def get_conn():
    return get_connection()


conn = get_conn()


# ─────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────
def to_df(data: list) -> pd.DataFrame:
    """Convert list-of-dicts to DataFrame, returning empty DF on failure."""
    if not data:
        return pd.DataFrame()
    return pd.DataFrame(data)


def show_error(msg: str):
    st.error(f"⚠️ {msg}")


def show_success(msg: str):
    st.success(f"✅ {msg}")


def section_header(title: str, subtitle: str = ""):
    st.markdown(f'<p class="section-header">{title}</p>', unsafe_allow_html=True)
    if subtitle:
        st.markdown(f'<p class="section-sub">{subtitle}</p>', unsafe_allow_html=True)


def divider():
    st.markdown('<div class="divider"></div>', unsafe_allow_html=True)


# ─────────────────────────────────────────────
#  SIDEBAR NAVIGATION
# ─────────────────────────────────────────────
with st.sidebar:
    st.markdown("## 🛒 E-Commerce\nAdmin Panel")
    st.markdown("---")
    page = st.radio(
        "Navigation",
        [
            "🏠 Dashboard",
            "📦 Products",
            "📊 Inventory",
            "🧾 Orders",
            "👥 Customers",
            "📈 Analytics",
        ],
        label_visibility="collapsed",
    )
    st.markdown("---")
    st.caption("© 2025 E-Commerce Admin")


# ═══════════════════════════════════════════════════════════════════
#  1 ▸ DASHBOARD
# ═══════════════════════════════════════════════════════════════════
if page == "🏠 Dashboard":
    section_header("🏠 Dashboard Overview", "Real-time snapshot of your store's performance")

    summary = analytics.dashboard_summary(conn)

    if summary:
        c1, c2, c3, c4, c5 = st.columns(5)
        c1.metric("👥 Total Users",     f"{summary.get('total_users', 0):,}")
        c2.metric("🧾 Total Orders",    f"{summary.get('total_orders', 0):,}")
        c3.metric("💰 Total Revenue",   f"${summary.get('total_revenue', 0):,.2f}")
        c4.metric("📦 Total Products",  f"{summary.get('total_products', 0):,}")
        c5.metric("⚠️ Low Stock",       f"{summary.get('low_stock_count', 0):,}")
    else:
        show_error("Could not load dashboard summary.")

    divider()

    col_l, col_r = st.columns(2)

    with col_l:
        st.subheader("🏆 Best Selling Products")
        best = analytics.best_selling_products(conn, limit=5)
        if best:
            df_best = to_df(best)
            fig, ax = plt.subplots(figsize=(5, 3))
            ax.barh(
                df_best["product_name"],
                df_best["total_quantity_sold"],
                color="#3b82f6",
                height=0.55,
            )
            ax.invert_yaxis()
            ax.set_xlabel("Units Sold", fontsize=9)
            ax.tick_params(labelsize=8)
            ax.spines[["top", "right"]].set_visible(False)
            fig.tight_layout()
            st.pyplot(fig)
            plt.close(fig)
        else:
            st.info("No sales data available.")

    with col_r:
        st.subheader("📂 Revenue by Category")
        cat_rev = analytics.revenue_by_category(conn)
        if cat_rev:
            df_cat = to_df(cat_rev)
            fig2, ax2 = plt.subplots(figsize=(5, 3))
            colours = plt.cm.Blues_r(
                [i / len(df_cat) for i in range(len(df_cat))]
            )
            ax2.bar(df_cat["category_name"], df_cat["total_revenue"], color=colours)
            ax2.yaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f"${x:,.0f}"))
            ax2.tick_params(axis="x", rotation=30, labelsize=8)
            ax2.tick_params(axis="y", labelsize=8)
            ax2.spines[["top", "right"]].set_visible(False)
            fig2.tight_layout()
            st.pyplot(fig2)
            plt.close(fig2)
        else:
            st.info("No category revenue data available.")


# ═══════════════════════════════════════════════════════════════════
#  2 ▸ PRODUCTS
# ═══════════════════════════════════════════════════════════════════
elif page == "📦 Products":
    section_header("📦 Products", "Manage your product catalogue")

    tab_list, tab_add, tab_delete = st.tabs(["📋 All Products", "➕ Add Product", "🗑️ Delete Product"])

    # ── All Products ──
    with tab_list:
        search_term = st.text_input("🔍 Search product by name", placeholder="e.g. Wireless Mouse")
        all_prods = products.get_all_products(conn)
        if all_prods:
            df_prods = to_df(all_prods)
            if search_term:
                mask = df_prods.apply(
                    lambda row: row.astype(str).str.contains(search_term, case=False).any(), axis=1
                )
                df_prods = df_prods[mask]
            st.caption(f"Showing {len(df_prods)} product(s)")
            st.dataframe(df_prods, use_container_width=True, hide_index=True)
        else:
            st.info("No products found.")

    # ── Add Product ──
    with tab_add:
        st.subheader("➕ Add New Product")
        with st.form("add_product_form", clear_on_submit=True):
            col1, col2 = st.columns(2)
            with col1:
                p_name  = st.text_input("Product Name *")
                p_price = st.number_input("Price ($) *", min_value=0.0, format="%.2f")
            with col2:
                p_cat   = st.number_input("Category ID *", min_value=1, step=1)
                p_desc  = st.text_area("Description", height=100)

            submitted = st.form_submit_button("🚀 Add Product", use_container_width=True)
            if submitted:
                if not p_name or p_price <= 0:
                    show_error("Product name and a valid price are required.")
                else:
                    ok, msg = products.add_product(conn, p_name, p_desc, p_price, p_cat)
                    show_success(msg) if ok else show_error(msg)

    # ── Delete Product ──
    with tab_delete:
        st.subheader("🗑️ Delete Product")
        del_id = st.number_input("Product ID to delete", min_value=1, step=1)
        if st.button("Delete Product", type="primary"):
            ok, msg = products.delete_product(conn, del_id)
            show_success(msg) if ok else show_error(msg)


# ═══════════════════════════════════════════════════════════════════
#  3 ▸ INVENTORY
# ═══════════════════════════════════════════════════════════════════
elif page == "📊 Inventory":
    section_header("📊 Inventory", "Track stock levels and manage replenishment")

    tab_inv, tab_low, tab_update = st.tabs(["📋 All Inventory", "⚠️ Low Stock", "✏️ Update Stock"])

    with tab_inv:
        inv_summary = inventory.inventory_summary(conn)
        if inv_summary:
            c1, c2, c3, c4 = st.columns(4)
            c1.metric("📦 Products Tracked",  inv_summary.get("total_products_in_inventory", 0))
            c2.metric("🗃️ Total Stock Units",  f'{inv_summary.get("total_stock_items", 0):,}')
            c3.metric("⚠️ Low Stock (<5)",     inv_summary.get("low_stock_count", 0))
            c4.metric("🕒 Last Updated",
                      str(inv_summary.get("last_updated_latest_date", "N/A"))[:10])
        divider()
        all_inv = inventory.get_all_inventory(conn)
        if all_inv:
            st.dataframe(to_df(all_inv), use_container_width=True, hide_index=True)
        else:
            st.info("No inventory records found.")

    with tab_low:
        threshold = st.slider("⚠️ Low Stock Threshold", min_value=1, max_value=100, value=10)
        low = inventory.low_stock_products(conn, threshold)
        if low:
            st.warning(f"{len(low)} product(s) below threshold of {threshold} units")
            st.dataframe(to_df(low), use_container_width=True, hide_index=True)
        else:
            st.success(f"All products are above {threshold} units. 🎉")

    with tab_update:
        st.subheader("✏️ Update Stock Quantity")
        with st.form("update_stock_form", clear_on_submit=True):
            upd_pid = st.number_input("Product ID *", min_value=1, step=1)
            upd_qty = st.number_input("New Stock Quantity *", min_value=0, step=1)
            if st.form_submit_button("💾 Update Stock", use_container_width=True):
                ok, msg = inventory.update_stock(conn, upd_pid, upd_qty)
                show_success(msg) if ok else show_error(msg)


# ═══════════════════════════════════════════════════════════════════
#  4 ▸ ORDERS
# ═══════════════════════════════════════════════════════════════════
elif page == "🧾 Orders":
    section_header("🧾 Orders", "Monitor and manage customer orders")

    status_filter = st.selectbox(
        "Filter by Status",
        ["All", "Pending", "Processing", "Shipped", "Delivered", "Cancelled"],
    )

    all_orders = orders.get_all_orders(conn)

    if all_orders:
        df_orders = to_df(all_orders)

        if status_filter != "All" and "status" in df_orders.columns:
            df_orders = df_orders[
                df_orders["status"].str.lower() == status_filter.lower()
            ]

        st.caption(f"Showing {len(df_orders)} order(s)")

        col_l, col_r = st.columns([2, 1])
        with col_l:
            st.dataframe(df_orders, use_container_width=True, hide_index=True)

        with col_r:
            st.subheader("🔍 Order Details")
            order_id_input = st.number_input("Enter Order ID", min_value=1, step=1)
            if st.button("Fetch Order Details"):
                detail = orders.get_order_by_id(conn, order_id_input)
                if detail:
                    with st.expander(f"📄 Order #{order_id_input}", expanded=True):
                        for key, val in detail.items():
                            st.markdown(f"**{key.replace('_', ' ').title()}:** {val}")
                else:
                    show_error(f"No order found with ID {order_id_input}.")
    else:
        st.info("No orders available.")


# ═══════════════════════════════════════════════════════════════════
#  5 ▸ CUSTOMERS
# ═══════════════════════════════════════════════════════════════════
elif page == "👥 Customers":
    section_header("👥 Customers", "View and analyse your customer base")

    tab_all, tab_summary = st.tabs(["📋 All Customers", "🔍 Purchase Summary"])

    with tab_all:
        all_custs = customers.get_all_customers(conn)
        if all_custs:
            df_custs = to_df(all_custs)
            search_cust = st.text_input("🔍 Search customer", placeholder="Name or email…")
            if search_cust:
                mask = df_custs.apply(
                    lambda row: row.astype(str).str.contains(search_cust, case=False).any(), axis=1
                )
                df_custs = df_custs[mask]
            st.caption(f"{len(df_custs)} customer(s) found")
            st.dataframe(df_custs, use_container_width=True, hide_index=True)
        else:
            st.info("No customers found.")

    with tab_summary:
        st.subheader("🔍 Customer Purchase Summary")
        cust_id = st.number_input("Enter Customer / User ID", min_value=1, step=1)
        if st.button("Get Summary"):
            summary = analytics.user_purchase_summary(conn, cust_id)
            if summary:
                c1, c2, c3 = st.columns(3)
                c1.metric("🧾 Total Orders",  summary.get("total_orders", 0))
                c2.metric("💰 Total Spent",   f"${summary.get('total_spent', 0):,.2f}")
                c3.metric("📅 Last Order",    str(summary.get("last_order_date", "N/A"))[:10])
            else:
                show_error(f"No data found for user ID {cust_id}.")


# ═══════════════════════════════════════════════════════════════════
#  6 ▸ ANALYTICS
# ═══════════════════════════════════════════════════════════════════
elif page == "📈 Analytics":
    section_header("📈 Analytics", "Business intelligence and performance insights")

    tab_sales, tab_ratings, tab_cart = st.tabs(
        ["💰 Sales & Revenue", "⭐ Product Ratings", "🛒 Cart Analysis"]
    )

    # ── Sales & Revenue ──
    with tab_sales:
        col_l, col_r = st.columns(2)

        with col_l:
            st.subheader("🏆 Best Selling Products")
            limit_n = st.slider("Top N Products", 3, 20, 10, key="bsp_slider")
            best = analytics.best_selling_products(conn, limit=limit_n)
            if best:
                df_b = to_df(best)
                fig, ax = plt.subplots(figsize=(5, max(3, len(df_b) * 0.45)))
                bars = ax.barh(df_b["product_name"], df_b["total_quantity_sold"],
                               color="#3b82f6", height=0.6)
                ax.bar_label(bars, fmt="%d", padding=4, fontsize=8)
                ax.invert_yaxis()
                ax.set_xlabel("Units Sold", fontsize=9)
                ax.tick_params(labelsize=8)
                ax.spines[["top", "right"]].set_visible(False)
                fig.tight_layout()
                st.pyplot(fig)
                plt.close(fig)
                st.dataframe(df_b, use_container_width=True, hide_index=True)
            else:
                st.info("No sales data.")

        with col_r:
            st.subheader("📂 Revenue by Category")
            cat_rev = analytics.revenue_by_category(conn)
            if cat_rev:
                df_cat = to_df(cat_rev)
                fig2, ax2 = plt.subplots(figsize=(5, 3.5))
                wedge_props = {"linewidth": 1.5, "edgecolor": "white"}
                ax2.pie(
                    df_cat["total_revenue"],
                    labels=df_cat["category_name"],
                    autopct="%1.1f%%",
                    wedgeprops=wedge_props,
                    startangle=140,
                    colors=plt.cm.Set2.colors,
                )
                ax2.set_title("Revenue Share by Category", fontsize=10)
                fig2.tight_layout()
                st.pyplot(fig2)
                plt.close(fig2)
                st.dataframe(df_cat, use_container_width=True, hide_index=True)
            else:
                st.info("No category revenue data.")

    # ── Product Ratings ──
    with tab_ratings:
        st.subheader("⭐ Product Rating Summary")
        ratings = analytics.product_rating_summary(conn)
        if ratings:
            df_r = to_df(ratings)

            fig3, ax3 = plt.subplots(figsize=(9, max(3, len(df_r) * 0.45)))
            colours = ["#f59e0b" if v >= 4 else "#94a3b8" for v in df_r["avg_rating"]]
            bars3 = ax3.barh(df_r["product_name"], df_r["avg_rating"], color=colours, height=0.55)
            ax3.bar_label(bars3, fmt="%.2f", padding=4, fontsize=8)
            ax3.set_xlim(0, 5.5)
            ax3.set_xlabel("Average Rating", fontsize=9)
            ax3.invert_yaxis()
            ax3.tick_params(labelsize=8)
            ax3.spines[["top", "right"]].set_visible(False)
            ax3.axvline(4.0, color="#ef4444", linewidth=1, linestyle="--", alpha=0.6)
            ax3.text(4.05, -0.6, "4.0 threshold", color="#ef4444", fontsize=7)
            fig3.tight_layout()
            st.pyplot(fig3)
            plt.close(fig3)

            st.dataframe(df_r, use_container_width=True, hide_index=True)
        else:
            st.info("No review data available.")

    # ── Cart Analysis ──
    with tab_cart:
        st.subheader("🛒 Cart Analysis")
        cart = analytics.cart_analysis(conn)
        if cart:
            st.metric("🛒 Total Items Currently in Carts", f'{cart.get("total_items_in_carts", 0):,}')
            divider()

            most_added = cart.get("most_added_products", [])
            if most_added:
                st.subheader("🔥 Most Added Products")
                df_ma = to_df(most_added)

                fig4, ax4 = plt.subplots(figsize=(7, max(3, len(df_ma) * 0.5)))
                ax4.barh(df_ma["product_name"], df_ma["times_added"],
                         color="#10b981", height=0.55)
                ax4.invert_yaxis()
                ax4.set_xlabel("Times Added to Cart", fontsize=9)
                ax4.tick_params(labelsize=8)
                ax4.spines[["top", "right"]].set_visible(False)
                fig4.tight_layout()
                st.pyplot(fig4)
                plt.close(fig4)

                st.dataframe(df_ma, use_container_width=True, hide_index=True)
            else:
                st.info("No cart product data.")
        else:
            st.info("No cart data available.")