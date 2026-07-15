-- ============================================================================
-- Query 01 — Fulfillment Overview
-- Overall on-time / late / pending rate, calculated at ORDER level
-- (not order-line level — an order with 3 line items should not count 3x)
-- ============================================================================

SELECT
    ship_status,
    COUNT(DISTINCT order_id)                                              AS total_orders,
    ROUND(COUNT(DISTINCT order_id) * 100.0
        / SUM(COUNT(DISTINCT order_id)) OVER (), 2)                       AS pct_of_orders
FROM orders
GROUP BY ship_status
ORDER BY total_orders DESC;

-- Expected result (Dec 2023 - Oct 2025, 830 orders):
--   On time   772   93.01%
--   Late       37    4.46%
--   Pending    21    2.53%


-- ----------------------------------------------------------------------------
-- Revenue base for context (line-level, since net_sales lives on the fact
-- table at product-line grain)
-- ----------------------------------------------------------------------------
SELECT
    ROUND(SUM(net_sales), 2)                                              AS total_net_sales,
    ROUND(SUM(net_sales)
        / (DATE_PART('day', MAX(order_date) - MIN(order_date)) / 365.25), 2) AS annualized_net_sales,
    COUNT(DISTINCT order_id)                                              AS total_orders,
    ROUND(SUM(net_sales) / COUNT(DISTINCT order_id), 2)                    AS avg_order_value
FROM fact_order_lines;

-- Expected result:
--   total_net_sales        1,265,792.95
--   annualized_net_sales     689,017.70
--   total_orders                   830
--   avg_order_value           1,525.05
