# Business Brief — Order Fulfillment & Revenue Risk Analysis

## Company Context

**Boga Nusantara** is an Indonesia-based B2B distributor and exporter of
specialty food & beverage products (beverages, dairy, confections, meat &
poultry, seafood, produce, condiments, grains/cereals), supplying retailers,
specialty grocers, and HORECA partners across Europe, North America, and
South America.

## Problem Statement

Boga Nusantara's on-time delivery rate is **93.0%** — inside the "good" tier
for retail/distribution (93–95%) but short of the 95%+ threshold considered
excellent industry-wide. More importantly, the sales and ops teams have no
systematic way to see **where** that risk concentrates: which carriers,
which regions, and — most critically — which customers are repeatedly
affected and therefore most likely to churn.

## SMART Objective

Identify where and why delivery failures concentrate, and deliver
data-driven recommendations to raise on-time delivery from **93% to 96%+
within 6 months**, protecting the revenue base most exposed to churn —
monitored through a real-time dashboard.

## Scope

**In scope**
- Order and shipment data from **Dec 2023 – Oct 2025**: 830 orders / 2,155
  order lines, 89 B2B customers, 3 shipping carriers, 8 product categories,
  21 countries.
- Delivery outcomes evaluated at the **order level** (not line-item level —
  see `02_data_discovery/data_dictionary.md` for why this matters) across
  three lenses: Shipper (carrier), Customer, and Country/Region.

**Out of scope**
- Warehouse-level operations, inventory availability, and product-level
  return rates were not analyzed — the focus is order-level delivery
  reliability and its concentration risk to revenue.

## Tools & Methodology

| Stage | Tool |
|---|---|
| Data preparation & star-schema modeling | Python (pandas) |
| Data analysis | PostgreSQL (window functions, CTEs) |
| Insight & recommendation | Manual synthesis against cited industry benchmarks |
| Dashboard | Power BI |

See `04_analysis/sql/` for the full query set and
`03_data_preparation/data_preparation.py` for the cleaning/modeling script.

## Deliverables

1. Star-schema dataset (`data/raw/`) with a documented data dictionary
2. PostgreSQL analysis queries (`04_analysis/sql/queries/`)
3. Interactive Power BI companion dashboard (`dashboard/`)
4. A 24-slide analysis deck with findings, recommendations, and ROI (`deck/`)
5. This repository, structured to be reproducible end-to-end

## A Note on the Dataset

The underlying data is a Northwind-style B2B order/shipment dataset — a
widely used dataset for SQL/BI training — extended with derived fields
(`net_sales`, `freight_alloc`, `ship_status`, `price_band`, etc.) and
reframed under the fictional Boga Nusantara identity for this case study.
Full provenance and industry benchmark citations are in
`02_data_discovery/data_dictionary.md` and the deck's Appendix A.
