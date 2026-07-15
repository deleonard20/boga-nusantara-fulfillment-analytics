-- ============================================================================
-- Query 02 — Carrier (Shipper) Performance
-- Late-rate frequency AND average delay severity per carrier.
-- Deliberately kept separate: a carrier can be "reliable" (low frequency)
-- but still costly when it does fail (high severity) — see Speedy Express.
-- ============================================================================

-- ---- Frequency: late rate by carrier -----------------------------------
SELECT
    shipper_name,
    COUNT(*)                                                              AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1)                    AS pct_of_volume,
    SUM(is_late)                                                          AS late_orders,
    ROUND(AVG(is_late) * 100, 2)                                          AS late_rate_pct
FROM orders
GROUP BY shipper_name
ORDER BY late_rate_pct DESC;

-- Expected result:
--   shipper_name        total_orders  pct_of_volume  late_orders  late_rate_pct
--   United Package             326          39.3           16           4.9
--   Speedy Express              249          30.0           12           4.8
--   Federal Shipping            255          30.7            9           3.5


-- ---- Severity: average delay (days) when a shipment IS late -------------
SELECT
    shipper_name,
    COUNT(*)                                            AS late_orders,
    ROUND(AVG(shipped_date - required_date), 1)          AS avg_delay_days
FROM orders
WHERE ship_status = 'Late'
GROUP BY shipper_name
ORDER BY avg_delay_days DESC;

-- Expected result:
--   shipper_name        late_orders  avg_delay_days
--   Speedy Express               12             8.1
--   United Package               16             5.6
--   Federal Shipping              9             5.6
