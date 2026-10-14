-- Olist E-Commerce Analytics
-- File: 02_sales_revenue_analysis.sql
-- Purpose: Analyse product revenue, freight, order value, and monthly trends.
-- BigQuery Standard SQL

-- 2.1 Overall revenue summary.
-- Revenue here is based on order_items.price plus order_items.freight_value.
WITH order_totals AS (
  SELECT
    order_id,
    SUM(price) AS product_revenue,
    SUM(freight_value) AS freight_revenue,
    SUM(price + freight_value) AS order_value
  FROM `e-commerce-analytics-509507.olist_ecommerce.order_items`
  GROUP BY order_id
)
SELECT
  COUNT(*) AS orders_with_items,
  ROUND(SUM(product_revenue), 2) AS total_product_revenue,
  ROUND(SUM(freight_revenue), 2) AS total_freight_revenue,
  ROUND(SUM(order_value), 2) AS total_order_value_including_freight,
  ROUND(AVG(order_value), 2) AS average_order_value_including_freight
FROM order_totals;

-- 2.2 Monthly revenue trend, based on order purchase month.
WITH order_totals AS (
  SELECT
    order_id,
    SUM(price) AS product_revenue,
    SUM(freight_value) AS freight_revenue,
    SUM(price + freight_value) AS order_value
  FROM `e-commerce-analytics-509507.olist_ecommerce.order_items`
  GROUP BY order_id
)
SELECT
  FORMAT_DATE('%Y-%m', DATE(o.order_purchase_timestamp)) AS purchase_month,
  COUNT(DISTINCT o.order_id) AS orders_with_items,
  ROUND(SUM(t.product_revenue), 2) AS product_revenue,
  ROUND(SUM(t.freight_revenue), 2) AS freight_revenue,
  ROUND(SUM(t.order_value), 2) AS total_order_value
FROM `e-commerce-analytics-509507.olist_ecommerce.orders` AS o
JOIN order_totals AS t USING (order_id)
GROUP BY purchase_month
ORDER BY purchase_month;

-- 2.3 Revenue by order status.
WITH order_totals AS (
  SELECT
    order_id,
    SUM(price) AS product_revenue,
    SUM(freight_value) AS freight_revenue,
    SUM(price + freight_value) AS order_value
  FROM `e-commerce-analytics-509507.olist_ecommerce.order_items`
  GROUP BY order_id
)
SELECT
  o.order_status,
  COUNT(DISTINCT o.order_id) AS orders_with_items,
  ROUND(SUM(t.product_revenue), 2) AS product_revenue,
  ROUND(SUM(t.freight_revenue), 2) AS freight_revenue,
  ROUND(SUM(t.order_value), 2) AS total_order_value
FROM `e-commerce-analytics-509507.olist_ecommerce.orders` AS o
JOIN order_totals AS t USING (order_id)
GROUP BY o.order_status
ORDER BY total_order_value DESC;

-- 2.4 Average order value by month.
WITH order_totals AS (
  SELECT order_id, SUM(price + freight_value) AS order_value
  FROM `e-commerce-analytics-509507.olist_ecommerce.order_items`
  GROUP BY order_id
)
SELECT
  FORMAT_DATE('%Y-%m', DATE(o.order_purchase_timestamp)) AS purchase_month,
  COUNT(*) AS orders_with_items,
  ROUND(AVG(t.order_value), 2) AS average_order_value
FROM `e-commerce-analytics-509507.olist_ecommerce.orders` AS o
JOIN order_totals AS t USING (order_id)
GROUP BY purchase_month
ORDER BY purchase_month;
