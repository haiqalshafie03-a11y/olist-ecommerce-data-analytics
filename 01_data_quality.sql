-- Olist E-Commerce Analytics
-- File: 01_data_quality.sql
-- Purpose: Check row counts, duplicate keys, missing values, and date consistency.
-- BigQuery Standard SQL

-- 1.1 Row counts for core tables
SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM `e-commerce-analytics-509507.olist_ecommerce.customers`
UNION ALL
SELECT 'orders', COUNT(*)
FROM `e-commerce-analytics-509507.olist_ecommerce.orders`
UNION ALL
SELECT 'order_items', COUNT(*)
FROM `e-commerce-analytics-509507.olist_ecommerce.order_items`
UNION ALL
SELECT 'products', COUNT(*)
FROM `e-commerce-analytics-509507.olist_ecommerce.products`;

-- 1.2 Check duplicate customer_id values.
-- customer_unique_id can legitimately appear more than once because one customer
-- may have more than one customer_id record in the source data.
SELECT
  COUNT(*) AS total_customer_rows,
  COUNT(DISTINCT customer_id) AS distinct_customer_ids,
  COUNT(*) - COUNT(DISTINCT customer_id) AS duplicate_customer_id_rows,
  COUNTIF(customer_id IS NULL) AS null_customer_ids,
  COUNTIF(customer_unique_id IS NULL) AS null_customer_unique_ids
FROM `e-commerce-analytics-509507.olist_ecommerce.customers`;

-- 1.3 Check missing values in important order fields.
SELECT
  COUNT(*) AS total_orders,
  COUNTIF(order_id IS NULL) AS missing_order_id,
  COUNTIF(customer_id IS NULL) AS missing_customer_id,
  COUNTIF(order_purchase_timestamp IS NULL) AS missing_purchase_timestamp,
  COUNTIF(order_approved_at IS NULL) AS missing_approved_timestamp,
  COUNTIF(order_delivered_carrier_date IS NULL) AS missing_carrier_timestamp,
  COUNTIF(order_delivered_customer_date IS NULL) AS missing_delivery_timestamp,
  COUNTIF(order_estimated_delivery_date IS NULL) AS missing_estimated_delivery_date
FROM `e-commerce-analytics-509507.olist_ecommerce.orders`;

-- 1.4 Check duplicate order IDs.
SELECT
  COUNT(*) AS total_order_rows,
  COUNT(DISTINCT order_id) AS distinct_order_ids,
  COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_order_id_rows
FROM `e-commerce-analytics-509507.olist_ecommerce.orders`;

-- 1.5 Check order date logic. These are flags for investigation, not automatic proof
-- that the entire record is invalid.
SELECT
  COUNT(*) AS total_orders,
  COUNTIF(order_approved_at < order_purchase_timestamp) AS approved_before_purchase,
  COUNTIF(order_delivered_carrier_date < order_approved_at) AS carrier_before_approval,
  COUNTIF(order_delivered_customer_date < order_delivered_carrier_date) AS delivered_before_carrier,
  COUNTIF(order_delivered_customer_date < order_purchase_timestamp) AS delivered_before_purchase
FROM `e-commerce-analytics-509507.olist_ecommerce.orders`;

-- 1.6 Check product category completeness.
SELECT
  COUNT(*) AS total_products,
  COUNTIF(product_id IS NULL) AS missing_product_id,
  COUNTIF(product_category_name IS NULL) AS missing_category
FROM `e-commerce-analytics-509507.olist_ecommerce.products`;
