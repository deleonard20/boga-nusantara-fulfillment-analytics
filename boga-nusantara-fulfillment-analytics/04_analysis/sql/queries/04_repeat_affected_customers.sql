-- ============================================================================
-- Query 04 — Repeat-Affected Customers (Revenue Concentration Risk)
-- The headline finding of this analysis: risk isn't evenly spread across
-- all 89 customers — it concentrates in a small group with 2+ late/pending
-- shipments. HAVING filters to customers with a large enough order history
-- (>= 3 orders) that "2 failures" is a real pattern, not noise.
-- ============================================================================

WITH customer_orders AS (
    SELECT
        o.customer_id,
        o.customer_name,
        COUNT(*)                                   AS total_orders,
        SUM(o.is_risk)                              AS risk_orders
    FROM orders o
    GROUP BY o.customer_id, o.customer_name
),
customer_revenue AS (
    SELECT
        customer_id,
        SUM(net_sales)                              AS total_net_sales
    FROM fact_order_lines
    GROUP BY customer_id
)
SELECT
    co.customer_name,
    co.total_orders,
    co.risk_orders,
    ROUND(co.risk_orders * 100.0 / co.total_orders, 1)  AS risk_rate_pct,
    ROUND(cr.total_net_sales, 2)                        AS total_net_sales
FROM customer_orders co
JOIN customer_revenue cr ON cr.customer_id = co.customer_id
WHERE co.total_orders >= 3
  AND co.risk_orders  >= 2
ORDER BY cr.total_net_sales DESC;

-- Expected result: 13 customers, headed by QUICK-Stop ($110,277) and
-- Ernst Handel ($104,875). Together they total $434,307 in historical
-- revenue (34.3% of the $1,265,793 revenue base) despite being only
-- 13 of 89 customers (14.6%).


-- ---- Roll-up: the concentration stat used throughout the deck -----------
WITH flagged AS (
    SELECT o.customer_id
    FROM orders o
    GROUP BY o.customer_id
    HAVING COUNT(*) >= 3
       AND SUM(o.is_risk) >= 2
)
SELECT
    (SELECT COUNT(*) FROM flagged)                                        AS at_risk_customers,
    (SELECT COUNT(DISTINCT customer_id) FROM orders)                       AS total_customers,
    ROUND((SELECT COUNT(*) FROM flagged) * 100.0
        / (SELECT COUNT(DISTINCT customer_id) FROM orders), 1)             AS at_risk_customer_pct,
    ROUND((SELECT SUM(net_sales) FROM fact_order_lines
           WHERE customer_id IN (SELECT customer_id FROM flagged)), 2)     AS at_risk_revenue,
    ROUND((SELECT SUM(net_sales) FROM fact_order_lines
           WHERE customer_id IN (SELECT customer_id FROM flagged)) * 100.0
        / (SELECT SUM(net_sales) FROM fact_order_lines), 1)                AS at_risk_revenue_pct;

-- Expected result: 13 | 89 | 14.6 | 434307.27 | 34.3
