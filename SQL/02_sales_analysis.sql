-- ============================================================
-- OLIST E-COMMERCE ANALYSIS
-- 02_sales_analysis.sql
-- Purpose: Analyse sales performance, revenue trends
--          and customer payment behaviour.
-- ============================================================


-- 1. Monthly revenue
-- Revenue is restricted to successfully delivered orders.

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY month;


-- 2. Monthly revenue and month-on-month growth

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
),
revenue_comparison AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_revenue
    FROM monthly_revenue
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND(
        100.0 * (revenue - previous_revenue) / previous_revenue,
        2
    ) AS growth_percentage
FROM revenue_comparison
ORDER BY month;


-- 3. Revenue by customer state

SELECT
    c.customer_state,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN customers c
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- 4. Payment method analysis

SELECT
    p.payment_type,
    COUNT(*) AS payment_count,
    ROUND(SUM(p.payment_value), 2) AS total_payment_value
FROM payments p
GROUP BY p.payment_type
ORDER BY total_payment_value DESC;


-- 5. Credit-card instalment analysis
-- Zero-instalment records are excluded as anomalous.
-- Only instalment groups with at least 100 observations are
-- retained to avoid drawing conclusions from very small samples.

SELECT
    p.payment_installments,
    COUNT(*) AS payment_count,
    ROUND(SUM(p.payment_value), 2) AS total_payment_value,
    ROUND(AVG(p.payment_value), 2) AS average_payment_value
FROM payments p
WHERE p.payment_type = 'credit_card'
  AND p.payment_installments > 0
GROUP BY p.payment_installments
HAVING COUNT(*) >= 100
ORDER BY p.payment_installments;


/*
KEY ANALYTICAL NOTES

- Revenue metrics use delivered orders only to represent
  realised sales.

- Monthly revenue growth is calculated using LAG() to compare
  each month with the previous month.

- Geographic analysis uses customer state to identify where
  sales revenue is concentrated.

- Credit cards are the dominant payment method in the dataset.

- Higher-value credit-card purchases tend to be associated
  with greater numbers of instalments. This represents an
  association and should not be interpreted as causation.
*/