-- Olist E-Commerce Analytics
-- File: 03_product_category_analysis.sql
-- Purpose: Rank product categories by revenue, orders, and item volume.
-- BigQuery Standard SQL

-- 3.1 Top categories by product revenue.
SELECT
  COALESCE(p.product_category_name, 'unknown_or_missing') AS product_category,
  COUNT(DISTINCT oi.order_id) AS order_count,
  COUNT(*) AS item_count,
  ROUND(SUM(oi.price), 2) AS product_revenue,
  ROUND(SUM(oi.freight_value), 2) AS freight_revenue,
  ROUND(SUM(oi.price + oi.freight_value), 2) AS revenue_including_freight
FROM `e-commerce-analytics-509507.olist_ecommerce.order_items` AS oi
LEFT JOIN `e-commerce-analytics-509507.olist_ecommerce.products` AS p
  USING (product_id)
GROUP BY product_category
ORDER BY product_revenue DESC
LIMIT 20;

-- 3.2 Categories with the highest order volume.
SELECT
  COALESCE(p.product_category_name, 'unknown_or_missing') AS product_category,
  COUNT(DISTINCT oi.order_id) AS order_count,
  COUNT(*) AS item_count,
  ROUND(SUM(oi.price), 2) AS product_revenue
FROM `e-commerce-analytics-509507.olist_ecommerce.order_items` AS oi
LEFT JOIN `e-commerce-analytics-509507.olist_ecommerce.products` AS p
  USING (product_id)
GROUP BY product_category
ORDER BY order_count DESC
LIMIT 20;

-- 3.3 Average item price and freight by category.
SELECT
  COALESCE(p.product_category_name, 'unknown_or_missing') AS product_category,
  COUNT(*) AS item_count,
  ROUND(AVG(oi.price), 2) AS average_item_price,
  ROUND(AVG(oi.freight_value), 2) AS average_freight_value,
  ROUND(AVG(oi.price + oi.freight_value), 2) AS average_item_value_including_freight
FROM `e-commerce-analytics-509507.olist_ecommerce.order_items` AS oi
LEFT JOIN `e-commerce-analytics-509507.olist_ecommerce.products` AS p
  USING (product_id)
GROUP BY product_category
ORDER BY average_item_price DESC
LIMIT 20;

-- 3.4 Product category contribution to total product revenue.
WITH category_revenue AS (
  SELECT
    COALESCE(p.product_category_name, 'unknown_or_missing') AS product_category,
    SUM(oi.price) AS product_revenue
  FROM `e-commerce-analytics-509507.olist_ecommerce.order_items` AS oi
  LEFT JOIN `e-commerce-analytics-509507.olist_ecommerce.products` AS p
    USING (product_id)
  GROUP BY product_category
)
SELECT
  product_category,
  ROUND(product_revenue, 2) AS product_revenue,
  ROUND(100 * SAFE_DIVIDE(product_revenue, SUM(product_revenue) OVER ()), 2)
    AS percentage_of_product_revenue
FROM category_revenue
ORDER BY product_revenue DESC;
