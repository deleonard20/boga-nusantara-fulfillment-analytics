# Recommendations

Three targeted interventions, each tied to one of the three deep-dive
findings, projected to raise on-time delivery from **93% to 96%+ within 6
months** and protect the majority of the $236K/year revenue concentrated in
repeat-affected accounts.

---

## Fix #1 — Customer Concentration

**Finding:** 14.6% of customers (13 of 89) generate 34.3% of total revenue
($236K/year annualized) while having experienced 2+ late or unconfirmed
shipments.

**Why this happens**
- No systematic flag exists for a 2nd consecutive delivery failure
- Account ownership is split across sales and ops, so no one owns the
  follow-up
- Service recovery is reactive (triggered by complaints), not proactive

**Risk if unaddressed:** $236K/year stays exposed. Industry research shows
up to 50% of B2B buyers switch vendors after a poor service experience —
losing just 2–3 of these 13 accounts risks $50–70K/year.

**Recommendation**
1. **Account Health Monitoring** — Flag any customer after their 2nd
   late/pending shipment within a rolling 6-month window; route to a
   dedicated account owner for proactive outreach. *Tool: customer risk
   scorecard.*
2. **Priority Fulfillment** — Route flagged accounts' orders through the
   most reliable carrier (Federal Shipping) with added dispatch QA checks.
   *Tool: fulfillment priority queue.*

**Expected impact:** Cut the repeat-failure rate among flagged accounts in
half within 6 months — protecting an estimated **$118K+** of the $236K
exposure.

---

## Fix #2 — Carrier Performance

**Finding:** Federal Shipping is the most reliable carrier (3.5% late),
while United Package has the highest late frequency (4.9% on 39% of total
volume) and Speedy Express takes 45% longer to recover once a shipment is
late (8.1 vs 5.6 days average).

**Risk if unaddressed:** United Package carries the most order volume *and*
the highest late rate — compounding risk on the business's single biggest
shipping lane.

**Recommendation**
1. **Carrier Scorecard & SLA Review** — Track on-time % and average delay
   days per carrier quarterly; formalize SLA penalty clauses with
   underperforming carriers. *Tool: carrier performance scorecard.*
2. **Volume Rebalancing** — Route time-sensitive or high-value orders,
   especially from flagged at-risk accounts, preferentially through Federal
   Shipping. *Tool: rules-based carrier routing.*

**Expected impact:** Narrow the carrier late-rate gap from 1.4pp to under
0.5pp, and cut average recovery time for delayed shipments by 2–3 days
within 6 months.

---

## Fix #3 — Regional Lead Time

**Finding:** When shipments to South America are late, they take 11.2 days
on average to arrive — over 2.5x North America's 4.4 days — even though
South America is not the region with the most frequent delays.

**Root cause hypothesis** *(requires validation — see next steps)*
1. Promised delivery windows are based on average transit time, not
   region-specific customs/logistics variability
2. Reliance on the same 3 global carriers for every region, without local
   last-mile partners in more complex markets

**Risk if unaddressed:** Customers in South America and select European
markets (Sweden, Ireland) keep receiving unrealistic delivery promises,
denting trust even when the delay itself is outside Boga Nusantara's
direct control.

**Recommendation**
1. **Validate Root Cause First** — Audit carrier transit logs and customs
   clearance data for South American shipments to confirm whether delays
   originate in-transit or at customs. *Tool: carrier transit-time audit.*
2. **Region-Adjusted Lead Times** — Build a buffer into promised delivery
   dates for higher-variability regions, and evaluate local last-mile
   partners for South America. *Tool: region-adjusted lead-time model.*

**Expected impact:** Reduce South America's average delay severity from
11.2 to under 7 days within 6 months.

---

## 6-Month Roadmap

**Phase 1 — Implement (Month 1–2)**
- Stand up the customer risk scorecard; flag the 13 known repeat-affected
  accounts immediately
- Launch the carrier scorecard and formalize SLA review cadence
- Kick off the South America transit-time audit

**Phase 2 — Monitor (Month 3–4)**
- Track on-time rate progress toward 96%+ via the Power BI dashboard
- Monthly refresh of the at-risk customer list — catch new repeat-failures
  early
- Pilot region-adjusted lead times for South America based on audit
  findings

**Phase 3 — Evaluate (Month 5–6)**
- Measure protected revenue against the $118K+ target
- Adjust carrier volume allocation and lead-time buffers based on results
- Report ROI and on-time delivery trajectory to leadership

---

## What's the ROI?

| Metric | Target |
|---|---|
| On-time delivery rate | 93.0% → 96%+ |
| At-risk revenue protected | ~$118K+ of $236K annual exposure |
| Monitoring | Real-time Power BI dashboard |
