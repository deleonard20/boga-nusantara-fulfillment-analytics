# Data Dictionary

## Source & Provenance

Northwind-style B2B order/shipment dataset (a widely used sample dataset for
SQL/BI training), reframed under the fictional **Boga Nusantara** distributor
identity for this case study. Derived analytical fields (`net_sales`,
`freight_alloc`, `ship_status`, `price_band`, `is_late`, `is_risk`) were
added during data preparation — see `03_data_preparation/data_preparation.py`.

| | |
|---|---|
| Period covered | Dec 16, 2023 – Oct 17, 2025 (≈ 1.84 years) |
| Order lines (fact grain) | 2,155 |
| Distinct orders | 830 |
| Customers | 89 |
| Products | 77 across 8 categories |
| Shippers (carriers) | 3 |
| Employees (sales reps) | 9 |
| Countries served | 21 |

## ⚠️ Grain matters: order-level vs. line-level

The fact table's grain is **one row per product line per order** (2,155
rows). Order-level attributes — `ship_status`, `shipper_id`, `customer_id`,
dates — repeat across every line of the same order. Any "% of orders"
statistic (on-time rate, carrier late rate, etc.) must first deduplicate to
`order_id` (830 distinct orders), or multi-line orders get counted more than
once and silently inflate the denominator. Every query in
`04_analysis/sql/queries/` does this correctly via the `orders` compatibility
view — see `04_analysis/sql/schema/01_create_tables.sql`.

## `fact_order_lines`

| Column | Type | Description |
|---|---|---|
| `order_id` | int | Order identifier. Multiple rows share the same `order_id` (one per product line). |
| `product_id` | int | FK → `dim_products` |
| `customer_id` | varchar(10) | FK → `dim_customers` |
| `employee_id` | int | FK → `dim_employees` (sales rep who owns the order) |
| `shipper_id` | int | FK → `dim_shippers` (3rd-party carrier) |
| `order_date` | date | Date the order was placed |
| `required_date` | date | Promised/requested delivery date |
| `shipped_date` | date | Actual ship date (null if not yet shipped) |
| `ship_status` | varchar(10) | `On time` / `Late` / `Pending` — see note below |
| `ship_city`, `ship_region`, `ship_postal_code`, `ship_country` | varchar | Delivery destination |
| `trx_unit_price` | numeric | Transacted unit price for this line (after any per-line pricing) |
| `quantity` | int | Units ordered on this line |
| `discount` | numeric | Discount amount applied to this line |
| `discount_pct` | int | Discount as a percentage |
| `net_sales` | numeric | Line revenue after discount |
| `freight_alloc` | numeric | Freight cost allocated to this line |
| `sales_plus_freight` | numeric | `net_sales + freight_alloc` |
| `is_late` | smallint | 1 if `ship_status = 'Late'` — derived |
| `is_risk` | smallint | 1 if `ship_status IN ('Late','Pending')` — derived |

### `ship_status` — read this before building anything on it

- **On time** (93.01% of orders): shipped on or before `required_date`.
- **Late** (4.46%): shipped after `required_date`. This is the only
  unambiguous failure signal in the data.
- **Pending** (2.53%): `shipped_date` is null. **Every Pending order's
  `required_date` is still in the future** relative to the most recent
  `shipped_date` anywhere in the dataset (Oct 17, 2025) — i.e., these are
  simply orders that haven't reached their due date yet, not orders stuck
  or overdue. Treating Pending as equivalent to Late manufactures a false
  "spike" in the most recent month purely from this right-censoring effect
  (we caught this during analysis: the raw October figure looked like a
  28% failure rate until this was accounted for). Use `is_risk` for
  headline "not confirmed on-time" reporting; use `is_late` for any
  root-cause or driver analysis.

## `dim_customers`

| Column | Type | Description |
|---|---|---|
| `customer_id` | varchar(10) | Primary key |
| `customer_name` | varchar | Business/account name |
| `customer_contact` | varchar | Primary contact person |
| `customer_city`, `customer_region`, `customer_postal_code`, `customer_country` | varchar | Billing location |

## `dim_products`

| Column | Type | Description |
|---|---|---|
| `product_id` | int | Primary key |
| `product_name` | varchar | Product name |
| `category_id` | int | FK → `dim_categories` |
| `catalog_unit_price` | numeric | List price |
| `price_band` | varchar | Price banding (e.g. `10–20`, `20–50`) |

## `dim_categories`

| Column | Type | Description |
|---|---|---|
| `category_id` | int | Primary key |
| `category_name` | varchar | Beverages, Condiments, Confections, Dairy Products, Grains/Cereals, Meat/Poultry, Produce, Seafood |

## `dim_shippers`

| Column | Type | Description |
|---|---|---|
| `shipper_id` | int | Primary key |
| `shipper_name` | varchar | Federal Shipping, Speedy Express, United Package |

## `dim_employees`

| Column | Type | Description |
|---|---|---|
| `employee_id` | int | Primary key |
| `employee_name` | varchar | Sales rep name |
| `employee_title` | varchar | Job title |
| `employee_city`, `employee_country` | varchar | Home office location |

## Industry Benchmark References

Cited in the deck's Appendix A and used to set the 96%+ target:

1. Service Club (2025), *"On-Time Delivery Rate Benchmarks"* → retail/distribution "good" tier: 93–95%; "excellent": 95%+
2. MetricHQ, *"On-Time Delivery (OTD)"* → cross-sector performance tier reference
3. Rivo, *B2B Customer Retention Research* (2026) → up to 50% of B2B buyers switch vendors after a poor service experience; 89% cite service reliability as a primary reason to stay
