-- ============================================================================
-- Query 03 — Regional Delivery Severity
-- Maps ship_country into 3 macro-regions, then compares late-rate frequency
-- vs. average delay severity per region. South America is not the most
-- frequent offender, but it is by far the most severe when it happens.
-- ============================================================================

WITH regioned AS (
    SELECT
        *,
        CASE
            WHEN ship_country IN ('USA','Canada','Mexico')                THEN 'North America'
            WHEN ship_country IN ('Brazil','Venezuela','Argentina')        THEN 'South America'
            ELSE 'Europe'
        END AS region
    FROM orders
)
SELECT
    region,
    COUNT(*)                                                              AS total_orders,
    SUM(is_late)                                                          AS late_orders,
    ROUND(AVG(is_late) * 100, 2)                                          AS late_rate_pct,
    ROUND(AVG(CASE WHEN ship_status = 'Late'
                   THEN shipped_date - required_date END), 1)             AS avg_delay_days_when_late
FROM regioned
GROUP BY region
ORDER BY avg_delay_days_when_late DESC;

-- Expected result:
--   region            total_orders  late_orders  late_rate_pct  avg_delay_days_when_late
--   South America              145            6           4.1                      11.2
--   Europe                     505           24           4.8                       5.8
--   North America               180            7           3.9                       4.4
