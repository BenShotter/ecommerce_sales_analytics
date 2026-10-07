-- ============================================================
-- OLIST E-COMMERCE ANALYSIS
-- 05_cohort_analysis.sql
-- Purpose: Analyse customer retention by grouping customers
--          according to their first completed purchase month.
-- ============================================================


create view cohort_retention as WITH first_purchase AS (

    -- Identify each customer's first successfully delivered order
    -- and assign the customer to a monthly cohort.

    SELECT
        c.customer_unique_id,
        DATE_TRUNC(
            'month',
            MIN(o.order_purchase_timestamp)
        ) AS first_purchase_month
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),

customer_activity AS (

    -- Identify the months in which each customer completed
    -- a delivered order.

    SELECT
        c.customer_unique_id,
        DATE_TRUNC(
            'month',
            o.order_purchase_timestamp
        ) AS order_month,
        f.first_purchase_month
    FROM customers c
    JOIN first_purchase f
        ON c.customer_unique_id = f.customer_unique_id
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
),

cohort_data AS (

    -- Calculate the number of months between each order
    -- and the customer's first purchase.
    --
    -- cohort_index = 0: first purchase month
    -- cohort_index = 1: one month later
    -- cohort_index = 2: two months later, etc.

    SELECT
        customer_unique_id,
        first_purchase_month,
        order_month,

        (
            (
                EXTRACT(YEAR FROM order_month)
                - EXTRACT(YEAR FROM first_purchase_month)
            ) * 12
            +
            (
                EXTRACT(MONTH FROM order_month)
                - EXTRACT(MONTH FROM first_purchase_month)
            )
        )::INT AS cohort_index

    FROM customer_activity
),

cohort_counts AS (

    -- Count unique active customers for each cohort
    -- at each cohort index.

    SELECT
        first_purchase_month,
        cohort_index,
        COUNT(DISTINCT customer_unique_id) AS active_customers
    FROM cohort_data
    GROUP BY
        first_purchase_month,
        cohort_index
),

cohort_sizes AS (

    -- cohort_index 0 represents the original cohort size.
    -- The window function makes this value available for
    -- every subsequent month belonging to that cohort.

    SELECT
        first_purchase_month,
        cohort_index,
        active_customers,

        MAX(
            CASE
                WHEN cohort_index = 0
                THEN active_customers
            END
        ) OVER (
            PARTITION BY first_purchase_month
        ) AS cohort_size

    FROM cohort_counts
)

-- Calculate the percentage of the original cohort that
-- remained active in each subsequent month.

SELECT
    first_purchase_month,
    cohort_index,
    active_customers,
    cohort_size,

    ROUND(
        100.0 * active_customers / cohort_size,
        2
    ) AS retention_rate

FROM cohort_sizes ;