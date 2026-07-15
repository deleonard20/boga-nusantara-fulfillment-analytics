# 📦 Boga Nusantara Fulfillment Analytics
### Order Fulfillment & Revenue Risk Analysis — Boga Nusantara

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=flat&logo=postgresql&logoColor=white)
![PowerBI](https://img.shields.io/badge/Power%20BI-F2C811?style=flat&logo=powerbi&logoColor=black)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

---

## 📌 Project Overview

This project analyzes 22 months of B2B order and shipment data at **Boga
Nusantara**, an Indonesia-based specialty food & beverage distributor and
exporter supplying retailers, specialty grocers, and HORECA partners across
Europe, North America, and South America.

Boga Nusantara delivers **93.0% of orders on time** — inside the industry's
"good" tier, but short of the 95%+ benchmark for excellence. More
importantly, that risk is not evenly spread: just **13 of 89 customers
(14.6%)** have experienced 2+ late or unconfirmed shipments, yet they
represent **$236K in annualized revenue (34.3% of total sales)**.

This analysis identifies where delivery risk concentrates, why it happens,
and delivers three data-driven recommendations projected to raise on-time
delivery to **96%+** and protect an estimated **$118K+ in at-risk revenue**
within 6 months.

---

## ❓ Problem Statement

Boga Nusantara has no systematic way to see where delivery failures
concentrate or which customers are most exposed to churn as a result.
Without that visibility, sales and ops cannot prioritize interventions,
and high-value accounts silently accumulate repeat delivery failures until
they leave.

---

## 🎯 SMART Objective

Identify where and why delivery failures concentrate, and deliver
data-driven recommendations to raise on-time delivery from **93% to 96%+
within 6 months**, protecting the revenue base most exposed to churn —
monitored via a real-time Power BI dashboard.

---

## 🔍 Key Findings

| # | Finding | Impact |
|---|---------|--------|
| 1 | **Customer concentration risk** — 13 of 89 customers (14.6%) have 2+ late/pending shipments | $236K/year, 34.3% of total revenue, concentrated in a small segment |
| 2 | **Carrier performance gap** — Federal Shipping 3.5% late vs. United Package 4.9% (highest volume) vs. Speedy Express 4.8% but 45% slower to recover (8.1 vs 5.6 days) | Frequency and severity are two different problems needing two different fixes |
| 3 | **Regional delivery severity** — South America averages 11.2 days late vs. North America's 4.4 days (over 2.5x) despite not being the most frequent offender | Delivery promises may be systematically unrealistic for certain routes |
| 4 | **Pending ≠ Late** — every "Pending" order's required date is still in the future; treating it as a failure manufactures a false spike in the most recent month | Root-cause analysis correctly isolates confirmed `Late` shipments only |

---

## 💡 Recommendations

**1. Fix #1 — Customer Concentration (protect ~$118K+)**
- Flag any customer after a 2nd late/pending shipment in a rolling 6-month window; route to a dedicated account owner
- Route flagged accounts' orders through the most reliable carrier with added dispatch QA checks

**2. Fix #2 — Carrier Performance (narrow the gap to <0.5pp)**
- Track on-time % and average delay days per carrier quarterly; formalize SLA penalty clauses
- Route time-sensitive and at-risk-account orders preferentially through Federal Shipping

**3. Fix #3 — Regional Lead Time (cut South America severity to <7 days)**
- Audit carrier transit logs and customs data for South American shipments to validate root cause
- Build region-specific buffers into promised delivery dates; evaluate local last-mile partners

Full detail, "why this happens," and expected impact per fix: [`06_action/recommendations.md`](06_action/recommendations.md)

---

## 💰 Business Impact

| Metric | Value |
|--------|-------|
| Total Net Revenue (22 months) | $1,265,793 |
| Annualized Revenue | $689,018 |
| Current On-Time Delivery Rate | 93.0% |
| Target On-Time Delivery Rate | 96.0%+ |
| Revenue Concentrated in Repeat-Affected Accounts | $236,409/year (34.3%) |
| Customers Affected | 13 of 89 (14.6%) |
| **Estimated Revenue Protected at Target** | **~$118K+ annually** |

*(Revenue exposure = annualized net sales from customers with ≥2 late/pending shipments among ≥3 orders placed — this reflects revenue concentrated in accounts most likely to churn if reliability doesn't improve, not revenue already lost.)*

---

## 🛠 Tools & Methodology

| Stage | Tool | Activity |
|-------|------|----------|
| Data Preparation | Python (pandas) | Star-schema split, order-level dedup, `is_late`/`is_risk` derivation |
| Schema Design | PostgreSQL | Star schema DDL: 1 fact table + 5 dimension tables, FK constraints, indexes |
| Data Loading | PostgreSQL | `COPY`/`\copy` commands, row-count and FK integrity checks |
| Fulfillment Analysis | PostgreSQL | Order-level on-time/late/pending rates, carrier & regional breakdowns |
| Revenue Concentration | PostgreSQL | Repeat-affected customer identification, revenue-at-risk quantification |
| Seasonality Check | PostgreSQL | Quarter/year trend, right-censoring validation on `Pending` orders |
| Dashboard | Power BI | KPI cards, carrier & regional charts, shipping status breakdown, slicers |

---

## 📊 Analysis Deep Dive

### Layer 1 — Fulfillment Overview
| Metric | Value |
|--------|-------|
| Total Orders | 830 (2,155 order lines) |
| On Time | 772 (93.01%) |
| Late | 37 (4.46%) |
| Pending | 21 (2.53%) |
| Average Order Value | $1,525 |

**Critical insight:** Calculated at the *order* level, not the order-line
level — an order with 3 line items must not count 3x toward the on-time
rate. See [`02_data_discovery/data_dictionary.md`](02_data_discovery/data_dictionary.md) for why this distinction matters.

---

### Layer 2 — Carrier & Regional Analysis
| Carrier | Volume Share | Late Rate | Avg. Delay When Late |
|---------|--------------|-----------|----------------------|
| Federal Shipping | 30.7% | 3.5% (best) | 5.6 days |
| Speedy Express | 30.0% | 4.8% | 8.1 days (worst severity) |
| United Package | 39.3% (highest volume) | 4.9% (worst frequency) | 5.6 days |

| Region | Late Rate | Avg. Delay When Late |
|--------|-----------|----------------------|
| North America | 3.9% | 4.4 days |
| Europe | 4.8% | 5.8 days |
| South America | 4.1% | 11.2 days (worst severity) |

**Critical insight:** Frequency and severity are different problems.
United Package fails most *often*; Speedy Express and South America take
the *longest to recover* when they fail. A single "switch carriers"
response would only address half the issue.

---

### Layer 3 — Customer Concentration Risk
| Segment | Customers | % of Base | Revenue (annualized) | % of Revenue |
|---------|-----------|-----------|----------------------|---------------|
| Repeat-affected (2+ late/pending) | 13 | 14.6% | $236,409 | 34.3% |
| Rest of base | 76 | 85.4% | $452,609 | 65.7% |

**Critical insight:** Delivery risk is not evenly distributed. A small,
high-value customer segment carries an outsized share of revenue exposure —
losing even 2–3 of these 13 accounts, per industry churn research, could
mean $50–70K in lost annual revenue.

---

## 📊 Dashboard Preview

### Page 1 — Sales Overview
![Sales Overview](05_communication/screenshots/01_sales_overview.png)

### Page 2 — Customer & Shipping Insight
![Customer & Shipping Insight](05_communication/screenshots/02_customer_shipping_insight.png)

### Deck Companion — Fulfillment Risk Dashboard (design concept)
![Fulfillment Risk Dashboard Concept](05_communication/screenshots/03_fulfillment_risk_dashboard_concept.jpg)

**Dashboard Features:**
- **Page 1:** KPI cards (net sales, orders, quantity) · sales trend · sales by category · top 10 products
- **Page 2:** sales by country · top 5 customers · employee performance · shipping status breakdown
- **Deck concept view:** total orders, on-time rate, revenue-at-risk KPI cards · late rate by carrier · average delay by region

> **Note on scope:** `dashboard/Boga_Nusantara_Sales_Dashboard.pbix` is the
> interactive companion dashboard built for this dataset (general sales +
> shipping status overview, pages 1–2 above). The fulfillment-risk-specific
> view (page 3 above) currently exists as a native dashboard-style slide in
> the analysis deck; rebuilding it as a fully interactive `.pbix` page is
> the natural next iteration.

---

## 📁 Data Model

**Star Schema — 1 Fact Table + 5 Dimension Tables**

```
dim_customers    ──┐
dim_employees    ──┤
dim_shippers     ──┼──  fact_order_lines  (2,155 rows / 830 orders)
dim_products     ──┤
dim_categories   ──┘
```

| Table | Rows | Description |
|-------|------|-------------|
| `fact_order_lines` | 2,155 | Grain: 1 row = 1 product line within 1 order — revenue, freight, discount, ship status |
| `dim_customers` | 89 | Customer master: name, contact, location |
| `dim_products` | 77 | Product master: category, catalog price, price band |
| `dim_categories` | 8 | Beverages, Dairy, Confections, Meat/Poultry, Seafood, Produce, Condiments, Grains/Cereals |
| `dim_shippers` | 3 | Federal Shipping, Speedy Express, United Package |
| `dim_employees` | 9 | Sales rep master |

A compatibility view (`orders`) re-flattens the star schema back to one row
per order for straightforward order-level analysis — see
[`04_analysis/sql/schema/01_create_tables.sql`](04_analysis/sql/schema/01_create_tables.sql).

**Data Period:** Dec 2023 – Oct 2025 (22 months)
**Dataset:** Northwind-style B2B order/shipment dataset, reframed under the
Boga Nusantara identity for this case study — full provenance in
[`02_data_discovery/data_dictionary.md`](02_data_discovery/data_dictionary.md).

---

## 🔑 SQL Techniques Used

| Technique | Applied In |
|-----------|-----------|
| Window functions (`SUM() OVER()`) | Order-status share of total, carrier volume share |
| CTEs (multi-step) | Repeat-affected customer identification, regional severity |
| `CASE WHEN` region mapping | Country → macro-region classification |
| Conditional aggregation | `is_late` / `is_risk` rollups, late-rate-by-dimension |
| `HAVING` on aggregated conditions | Filtering to customers with ≥3 orders and ≥2 risk orders |
| Date arithmetic | Delay-days severity (`shipped_date - required_date`) |
| View abstraction | `orders` compatibility view over the star schema |

Full queries: [`04_analysis/sql/queries/`](04_analysis/sql/queries/)

---

## 📁 Project Structure

```
boga-nusantara-fulfillment-analytics/
├── 01_define/
│   └── business_brief.md
├── 02_data_discovery/
│   └── data_dictionary.md
├── 03_data_preparation/
│   └── data_preparation.py
├── 04_analysis/
│   └── sql/
│       ├── schema/
│       │   └── 01_create_tables.sql
│       └── queries/
│           ├── 01_fulfillment_overview.sql
│           ├── 02_carrier_performance.sql
│           ├── 03_regional_severity.sql
│           ├── 04_repeat_affected_customers.sql
│           └── 05_seasonality_trend.sql
├── 05_communication/
│   └── screenshots/
│       ├── 01_sales_overview.png
│       ├── 02_customer_shipping_insight.png
│       └── 03_fulfillment_risk_dashboard_concept.jpg
├── 06_action/
│   └── recommendations.md
├── data/
│   └── raw/
│       ├── fact_order_lines.csv
│       ├── dim_customers.csv
│       ├── dim_products.csv
│       ├── dim_categories.csv
│       ├── dim_shippers.csv
│       └── dim_employees.csv
├── deck/
│   └── Order_Fulfillment_Revenue_Risk_Analysis_Deleonard_Simanjorang.pptx
├── dashboard/
│   └── Boga_Nusantara_Sales_Dashboard.pbix
└── README.md
```

---

## 🎯 6-Month Implementation Roadmap

**Phase 1: Implement (Month 1–2)**
- Stand up the customer risk scorecard; flag the 13 known repeat-affected accounts
- Launch the carrier scorecard and formalize SLA review cadence
- Kick off the South America transit-time audit

**Phase 2: Monitor (Month 3–4)**
- Track on-time rate progress toward 96%+ via the Power BI dashboard
- Monthly refresh of the at-risk customer list
- Pilot region-adjusted lead times for South America

**Phase 3: Evaluate (Month 5–6)**
- Measure protected revenue against the $118K+ target
- Adjust carrier allocation and lead-time buffers based on results
- Report ROI and on-time delivery trajectory to leadership

Full roadmap: [`06_action/recommendations.md`](06_action/recommendations.md)

---

## 🔗 Connect

**Deleonard Simanjorang**
Data Analyst | People & Business Analytics

📧 deleonard20@gmail.com
💼 [LinkedIn](https://www.linkedin.com/in/deleonard-simanjorang)
📱 WhatsApp: +62 812 4154 4992
🐙 [GitHub](https://github.com/deleonard20)

---

**⭐ If you found this analysis helpful, please consider starring this repository!**
