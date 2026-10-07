-- ============================================================
-- OLIST E-COMMERCE ANALYSIS
-- 01_data_cleaning.sql
-- Purpose: Validate key fields and establish business rules
--          used throughout the analysis.
-- ============================================================


-- 1. Check missing values in key order fields

SELECT
    COUNT(*) FILTER (
        WHERE order_purchase_timestamp IS NULL
    ) AS missing_purchase_timestamp,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NULL
    ) AS missing_delivered_customer_date,

    COUNT(*) FILTER (
        WHERE order_estimated_delivery_date IS NULL
    ) AS missing_estimated_delivery_date,

    COUNT(*) FILTER (
        WHERE order_status IS NULL
    ) AS missing_order_status
FROM orders;


-- 2. Investigate missing delivery timestamps
-- Most missing delivery dates relate to orders that were not
-- successfully delivered.

SELECT
    order_status,
    COUNT(*) AS orders_missing_delivery_date
FROM orders
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY orders_missing_delivery_date DESC;


-- 3. Check delivered orders with missing delivery timestamps
-- Only 8 delivered orders have a missing actual delivery date.
-- These orders are retained for sales analysis but should be
-- excluded from analyses requiring an actual delivery timestamp.

SELECT
    COUNT(*) AS delivered_orders_missing_delivery_date
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;


-- 4. Validate product price and freight values

SELECT
    COUNT(*) FILTER (
        WHERE price IS NULL
    ) AS missing_price,

    COUNT(*) FILTER (
        WHERE price <= 0
    ) AS non_positive_price,

    COUNT(*) FILTER (
        WHERE freight_value IS NULL
    ) AS missing_freight,

    COUNT(*) FILTER (
        WHERE freight_value < 0
    ) AS negative_freight
FROM order_items;


-- 5. Inspect order statuses and associated revenue

SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(oi.price) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_status
ORDER BY revenue DESC;


/*
BUSINESS RULES

1. Final sales/revenue KPIs use delivered orders only.

   WHERE o.order_status = 'delivered'

   This prevents cancelled and incomplete transactions from being
   included in realised sales performance.

2. Customer cohort analysis also uses delivered orders so that
   retention represents customers completing subsequent purchases.

3. The 8 delivered orders with missing actual delivery timestamps
   are retained for sales analysis because they are classified as
   delivered. They should be excluded only from metrics requiring
   an actual delivery date.

4. No missing or non-positive product prices were identified.

5. No missing or negative freight values were identified.
*/