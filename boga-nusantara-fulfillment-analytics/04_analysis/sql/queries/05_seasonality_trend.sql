-- ============================================================================
-- Query 05 — Seasonality / Trend Check
-- Late rate by quarter and by year, using ONLY confirmed 'Late' shipments.
-- 'Pending' is deliberately excluded here — pending orders cluster in the
-- most recent month simply because they haven't reached their required
-- date yet (right-censoring), not because of a genuine seasonal problem.
-- Confirming this saved the analysis from a false "October crisis" read.
-- ============================================================================

SELECT
    EXTRACT(QUARTER FROM order_date)                                      AS order_quarter,
    COUNT(*)                                                              AS total_orders,
    SUM(is_late)                                                          AS late_orders,
    ROUND(AVG(is_late) * 100, 1)                                          AS late_rate_pct
FROM orders
GROUP BY order_quarter
ORDER BY order_quarter;

-- Expected result:
--   Q1   177 orders   11 late   6.2%
--   Q2   213 orders   10 late   4.7%
--   Q3   289 orders   10 late   3.5%
--   Q4   151 orders    6 late   4.0%


-- ---- Year-over-year check: is the problem getting better or worse? ------
SELECT
    EXTRACT(YEAR FROM order_date)                                         AS order_year,
    COUNT(*)                                                              AS total_orders,
    SUM(is_late)                                                          AS late_orders,
    ROUND(AVG(is_late) * 100, 1)                                          AS late_rate_pct
FROM orders
GROUP BY order_year
ORDER BY order_year;

-- Expected result: late rate improved from 5.2% (2024) to 4.0% (2025) —
-- the fulfillment problem is not worsening, which is why this analysis
-- recommends targeted fixes rather than a wholesale process overhaul.
