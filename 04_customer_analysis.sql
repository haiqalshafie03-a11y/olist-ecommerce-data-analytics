-- Olist E-Commerce Analytics
-- File: 04_customer_analysis.sql
-- Purpose: Analyse customer order frequency, spending segments, and state distribution.
-- BigQuery Standard SQL

-- Note: customer_unique_id is used to represent a customer across order records.
-- Customer spend is calculated from order item price plus freight.

-- 4.1 Customer order frequency and one-time/repeat customer counts.
WITH customer_orders AS (
  SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS order_count
  FROM `e-commerce-analytics-509507.olist_ecommerce.customers` AS c
  JOIN `e-commerce-analytics-509507.olist_ecommerce.orders` AS o
    USING (customer_id)
  GROUP BY c.customer_unique_id
)
SELECT
  CASE
    WHEN order_count = 1 THEN 'One-time'
    WHEN order_count > 1 THEN 'Repeat'
    ELSE 'No orders'
  END AS customer_type,
  COUNT(*) AS customer_count
FROM customer_orders
GROUP BY customer_type
ORDER BY customer_count DESC;

-- 4.2 Customer spending segments.
WITH order_totals AS (
  SELECT order_id, SUM(price + freight_value) AS order_value
  FROM `e-commerce-analytics-509507.olist_ecommerce.order_items`
  GROUP BY order_id
),
customer_spend AS (
  SELECT
    c.customer_unique_id,
    SUM(t.order_value) AS lifetime_spend
  FROM `e-commerce-analytics-509507.olist_ecommerce.customers` AS c
  JOIN `e-commerce-analytics-509507.olist_ecommerce.orders` AS o
    USING (customer_id)
  JOIN order_totals AS t USING (order_id)
  GROUP BY c.customer_unique_id
)
SELECT
  CASE
    WHEN lifetime_spend < 100 THEN 'Under R$100'
    WHEN lifetime_spend < 500 THEN 'R$100-R$499.99'
    WHEN lifetime_spend < 1000 THEN 'R$500-R$999.99'
    WHEN lifetime_spend < 5000 THEN 'R$1,000-R$4,999.99'
    ELSE 'R$5,000+'
  END AS spending_segment,
  COUNT(*) AS customer_count,
  ROUND(SUM(lifetime_spend), 2) AS segment_revenue
FROM customer_spend
GROUP BY spending_segment
ORDER BY
  CASE spending_segment
    WHEN 'Under R$100' THEN 1
    WHEN 'R$100-R$499.99' THEN 2
    WHEN 'R$500-R$999.99' THEN 3
    WHEN 'R$1,000-R$4,999.99' THEN 4
    ELSE 5
  END;

-- 4.3 Top states by number of unique customers.
SELECT
  c.customer_state,
  COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
  COUNT(DISTINCT o.order_id) AS order_count
FROM `e-commerce-analytics-509507.olist_ecommerce.customers` AS c
LEFT JOIN `e-commerce-analytics-509507.olist_ecommerce.orders` AS o
  USING (customer_id)
GROUP BY c.customer_state
ORDER BY unique_customers DESC
LIMIT 10;

-- 4.4 Average spend and order count per customer.
WITH order_totals AS (
  SELECT order_id, SUM(price + freight_value) AS order_value
  FROM `e-commerce-analytics-509507.olist_ecommerce.order_items`
  GROUP BY order_id
),
customer_summary AS (
  SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(t.order_value) AS lifetime_spend
  FROM `e-commerce-analytics-509507.olist_ecommerce.customers` AS c
  JOIN `e-commerce-analytics-509507.olist_ecommerce.orders` AS o
    USING (customer_id)
  JOIN order_totals AS t USING (order_id)
  GROUP BY c.customer_unique_id
)
SELECT
  COUNT(*) AS customers_with_orders,
  ROUND(AVG(order_count), 3) AS average_orders_per_customer,
  ROUND(AVG(lifetime_spend), 2) AS average_lifetime_spend,
  ROUND(SAFE_DIVIDE(COUNTIF(order_count > 1), COUNT(*)) * 100, 2)
    AS repeat_customer_rate_percent
FROM customer_summary;
