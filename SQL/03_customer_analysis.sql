-- ============================================================
-- OLIST E-COMMERCE ANALYSIS
-- 03_customer_analysis.sql
-- Purpose: Analyse customer value, repeat purchasing
--          and customer behaviour.
-- ============================================================


-- 1. Top customers by total spend
-- customer_unique_id is used because customer_id can vary
-- across different orders made by the same customer.

SELECT
    c.customer_unique_id,
    ROUND(SUM(oi.price), 2) AS total_spend
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY total_spend DESC
LIMIT 10;


-- 2. Top customers by number of completed orders

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS order_count
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY order_count DESC
LIMIT 10;


-- 3. Customers with more than one completed order

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    order_count
FROM customer_orders
WHERE order_count > 1
ORDER BY order_count DESC;


-- 4. Repeat customer rate

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    ROUND(
        100.0 *
        COUNT(*) FILTER (WHERE order_count > 1)
        / COUNT(*),
        2
    ) AS repeat_customer_rate
FROM customer_orders;


-- 5. Customer count by state

SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS customer_count
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY customer_count DESC;


/*
KEY ANALYTICAL NOTES

- customer_unique_id is used for customer-level analysis because
  it identifies the same customer across multiple orders.

- Delivered orders are used to define completed purchases.

- Repeat customers are defined as customers with more than one
  delivered order.

- Repeat customer rate measures the proportion of customers who
  completed at least two orders.

- Geographic customer counts can be compared with revenue by
  state to distinguish large customer bases from high-value
  regions.
*/