-- ============================================================
-- OLIST E-COMMERCE ANALYSIS
-- 04_product_analysis.sql
-- Purpose: Analyse product and category performance using
--          revenue, sales volume and average selling price.
-- ============================================================


-- 1. Top 10 product categories by revenue

SELECT
    ct.product_category_name_english AS category,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY ct.product_category_name_english
ORDER BY revenue DESC
LIMIT 10;


-- 2. Top 10 product categories by items sold

SELECT
    ct.product_category_name_english AS category,
    COUNT(*) AS items_sold
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY ct.product_category_name_english
ORDER BY items_sold DESC
LIMIT 10;


-- 3. Top 10 categories by average item price

SELECT
    ct.product_category_name_english AS category,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY ct.product_category_name_english
ORDER BY average_item_price DESC
LIMIT 10;


-- 4. Top 10 individual products by revenue

SELECT
    p.product_id,
    ct.product_category_name_english AS category,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(*) AS items_sold
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY
    p.product_id,
    ct.product_category_name_english
ORDER BY revenue DESC
LIMIT 10;


-- 5. Full category performance table
-- Useful as a source for Power BI because it retains all
-- categories rather than only the top 10.

SELECT
    ct.product_category_name_english AS category,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY ct.product_category_name_english
ORDER BY revenue DESC;


/*
KEY ANALYTICAL NOTES

- Only delivered orders are included in final product sales
  and revenue metrics.

- Category names are translated into English using the
  category_translation table.

- Revenue and sales volume are analysed separately because
  the category generating the most revenue is not necessarily
  the category selling the greatest number of items.

- Average item price provides additional context for explaining
  differences between revenue and sales-volume rankings.

- The full category performance query can be used as a source
  for Power BI visualisations.
*/