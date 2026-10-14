# Brazilian E-Commerce Data Analytics (Olist)

SQL portfolio project using Google BigQuery and Power BI.

## Dataset
Project: `e-commerce-analytics-509507`
Dataset: `olist_ecommerce`

The SQL files use these tables:
- `customers`
- `orders`
- `order_items`
- `products`

## SQL files
1. `01_data_quality.sql` — row counts, nulls, duplicate keys, and date checks.
2. `02_sales_revenue_analysis.sql` — revenue, monthly trends, status breakdown, and average order value.
3. `03_product_category_analysis.sql` — category revenue, order volume, item prices, and revenue share.
4. `04_customer_analysis.sql` — customer frequency, spending segments, state distribution, and repeat rate.
5. `05_order_fulfilment_analysis.sql` — status distribution, delivery time, delivery performance, and date flags.

## Before running
- Confirm all four table names and column names in BigQuery.
- These queries use BigQuery Standard SQL.
- Revenue is defined as `order_items.price` plus `order_items.freight_value`; this is not necessarily the same as payment totals.
- Results may differ from Power BI if the dashboard uses different filters, definitions, or customer counting logic.
- Do not commit credentials, API keys, or private data.

## How to run
Open each `.sql` file in BigQuery, run each query block separately, and compare the outputs with the expected metrics in your project.
