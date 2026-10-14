-- Olist E-Commerce Analytics
-- File: 05_order_fulfilment_analysis.sql
-- Purpose: Review order statuses, delivery times, and estimated delivery performance.
-- BigQuery Standard SQL

-- 5.1 Count and percentage of orders by status.
SELECT
  order_status,
  COUNT(*) AS order_count,
  ROUND(100 * SAFE_DIVIDE(COUNT(*), SUM(COUNT(*)) OVER ()), 2)
    AS percentage_of_orders
FROM `e-commerce-analytics-509507.olist_ecommerce.orders`
GROUP BY order_status
ORDER BY order_count DESC;

-- 5.2 Delivery time summary for orders with delivery timestamps.
SELECT
  COUNTIF(order_delivered_customer_date IS NOT NULL) AS delivered_orders_with_timestamp,
  ROUND(AVG(
    TIMESTAMP_DIFF(
      order_delivered_customer_date,
      order_purchase_timestamp,
      DAY
    )
  ), 2) AS average_days_from_purchase_to_delivery,
  APPROX_QUANTILES(
    TIMESTAMP_DIFF(
      order_delivered_customer_date,
      order_purchase_timestamp,
      DAY
    ), 100
  )[OFFSET(50)] AS median_days_from_purchase_to_delivery
FROM `e-commerce-analytics-509507.olist_ecommerce.orders`
WHERE order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date >= order_purchase_timestamp;

-- 5.3 Early, on-time, and late delivery compared with the estimated date.
SELECT
  CASE
    WHEN DATE(order_delivered_customer_date) < DATE(order_estimated_delivery_date)
      THEN 'Early'
    WHEN DATE(order_delivered_customer_date) = DATE(order_estimated_delivery_date)
      THEN 'On estimated date'
    WHEN DATE(order_delivered_customer_date) > DATE(order_estimated_delivery_date)
      THEN 'Late'
    ELSE 'Not delivered / missing date'
  END AS delivery_performance,
  COUNT(*) AS order_count
FROM `e-commerce-analytics-509507.olist_ecommerce.orders`
GROUP BY delivery_performance
ORDER BY order_count DESC;

-- 5.4 Average delivery duration by customer state.
SELECT
  c.customer_state,
  COUNT(DISTINCT o.order_id) AS delivered_order_count,
  ROUND(AVG(
    TIMESTAMP_DIFF(
      o.order_delivered_customer_date,
      o.order_purchase_timestamp,
      DAY
    )
  ), 2) AS average_days_to_delivery
FROM `e-commerce-analytics-509507.olist_ecommerce.orders` AS o
JOIN `e-commerce-analytics-509507.olist_ecommerce.customers` AS c
  USING (customer_id)
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp IS NOT NULL
  AND o.order_delivered_customer_date >= o.order_purchase_timestamp
GROUP BY c.customer_state
ORDER BY average_days_to_delivery DESC;

-- 5.5 Orders with potentially inconsistent date sequences.
SELECT
  order_id,
  order_status,
  order_purchase_timestamp,
  order_approved_at,
  order_delivered_carrier_date,
  order_delivered_customer_date,
  order_estimated_delivery_date,
  CASE
    WHEN order_approved_at < order_purchase_timestamp
      THEN 'Approval before purchase'
    WHEN order_delivered_carrier_date < order_approved_at
      THEN 'Carrier date before approval'
    WHEN order_delivered_customer_date < order_delivered_carrier_date
      THEN 'Delivery before carrier handoff'
    WHEN order_delivered_customer_date < order_purchase_timestamp
      THEN 'Delivery before purchase'
    ELSE 'Review other/missing date conditions'
  END AS date_quality_flag
FROM `e-commerce-analytics-509507.olist_ecommerce.orders`
WHERE (order_approved_at < order_purchase_timestamp)
   OR (order_delivered_carrier_date < order_approved_at)
   OR (order_delivered_customer_date < order_delivered_carrier_date)
   OR (order_delivered_customer_date < order_purchase_timestamp)
ORDER BY order_purchase_timestamp;
