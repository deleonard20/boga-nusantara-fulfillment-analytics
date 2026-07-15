-- ============================================================================
-- Boga Nusantara — Order Fulfillment & Revenue Risk Analysis
-- Star schema DDL: 1 fact table + 5 dimension tables
-- Source: Northwind-style B2B order/shipment dataset (data/raw/*.csv)
-- Target: PostgreSQL 13+
-- ============================================================================

DROP TABLE IF EXISTS fact_order_lines CASCADE;
DROP TABLE IF EXISTS dim_customers CASCADE;
DROP TABLE IF EXISTS dim_products CASCADE;
DROP TABLE IF EXISTS dim_categories CASCADE;
DROP TABLE IF EXISTS dim_shippers CASCADE;
DROP TABLE IF EXISTS dim_employees CASCADE;

-- ---------------------------------------------------------------------------
-- Dimension: categories
-- ---------------------------------------------------------------------------
CREATE TABLE dim_categories (
    category_id     INTEGER PRIMARY KEY,
    category_name   VARCHAR(50) NOT NULL
);

-- ---------------------------------------------------------------------------
-- Dimension: products
-- ---------------------------------------------------------------------------
CREATE TABLE dim_products (
    product_id          INTEGER PRIMARY KEY,
    product_name        VARCHAR(100) NOT NULL,
    category_id         INTEGER REFERENCES dim_categories(category_id),
    catalog_unit_price   NUMERIC(10,2),
    price_band          VARCHAR(20)
);

-- ---------------------------------------------------------------------------
-- Dimension: shippers (3rd-party carriers)
-- ---------------------------------------------------------------------------
CREATE TABLE dim_shippers (
    shipper_id      INTEGER PRIMARY KEY,
    shipper_name    VARCHAR(50) NOT NULL
);

-- ---------------------------------------------------------------------------
-- Dimension: employees (sales reps)
-- ---------------------------------------------------------------------------
CREATE TABLE dim_employees (
    employee_id         INTEGER PRIMARY KEY,
    employee_name       VARCHAR(100) NOT NULL,
    employee_title      VARCHAR(50),
    employee_city       VARCHAR(50),
    employee_country    VARCHAR(50)
);

-- ---------------------------------------------------------------------------
-- Dimension: customers (B2B distributor / retailer accounts)
-- ---------------------------------------------------------------------------
CREATE TABLE dim_customers (
    customer_id            VARCHAR(10) PRIMARY KEY,
    customer_name           VARCHAR(100) NOT NULL,
    customer_contact        VARCHAR(100),
    customer_city           VARCHAR(50),
    customer_region         VARCHAR(50),
    customer_postal_code    VARCHAR(20),
    customer_country        VARCHAR(50)
);

-- ---------------------------------------------------------------------------
-- Fact: order_lines
-- Grain: one row = one product line within one order
-- (order-level attributes such as ship_status/shipper/customer repeat
--  across every line of the same order_id — see the `orders` view below
--  for order-level analysis)
-- ---------------------------------------------------------------------------
CREATE TABLE fact_order_lines (
    order_id                INTEGER NOT NULL,
    product_id              INTEGER REFERENCES dim_products(product_id),
    customer_id             VARCHAR(10) REFERENCES dim_customers(customer_id),
    employee_id             INTEGER REFERENCES dim_employees(employee_id),
    shipper_id              INTEGER REFERENCES dim_shippers(shipper_id),
    order_date               DATE NOT NULL,
    required_date            DATE,
    shipped_date              DATE,
    ship_status               VARCHAR(10) NOT NULL CHECK (ship_status IN ('On time','Late','Pending')),
    ship_city                VARCHAR(50),
    ship_region               VARCHAR(50),
    ship_postal_code          VARCHAR(20),
    ship_country              VARCHAR(50),
    trx_unit_price            NUMERIC(10,2),
    quantity                 INTEGER,
    discount                 NUMERIC(10,2),
    discount_pct              INTEGER,
    net_sales                 NUMERIC(12,2),
    freight_alloc             NUMERIC(10,2),
    sales_plus_freight        NUMERIC(12,2),
    is_late                   SMALLINT NOT NULL,   -- 1 if ship_status = 'Late'
    is_risk                   SMALLINT NOT NULL,   -- 1 if ship_status IN ('Late','Pending')
    PRIMARY KEY (order_id, product_id)
);

CREATE INDEX idx_fact_order_id        ON fact_order_lines(order_id);
CREATE INDEX idx_fact_customer_id     ON fact_order_lines(customer_id);
CREATE INDEX idx_fact_shipper_id      ON fact_order_lines(shipper_id);
CREATE INDEX idx_fact_ship_status     ON fact_order_lines(ship_status);
CREATE INDEX idx_fact_order_date      ON fact_order_lines(order_date);

-- ---------------------------------------------------------------------------
-- COPY commands (run from repo root, psql)
-- ---------------------------------------------------------------------------
-- \copy dim_categories FROM 'data/raw/dim_categories.csv' WITH (FORMAT csv, HEADER true);
-- \copy dim_products   FROM 'data/raw/dim_products.csv'   WITH (FORMAT csv, HEADER true);
-- \copy dim_shippers   FROM 'data/raw/dim_shippers.csv'   WITH (FORMAT csv, HEADER true);
-- \copy dim_employees  FROM 'data/raw/dim_employees.csv'  WITH (FORMAT csv, HEADER true);
-- \copy dim_customers  FROM 'data/raw/dim_customers.csv'  WITH (FORMAT csv, HEADER true);
-- \copy fact_order_lines FROM 'data/raw/fact_order_lines.csv' WITH (FORMAT csv, HEADER true);

-- ---------------------------------------------------------------------------
-- Compatibility view: order-level, denormalized "orders" view.
-- Re-flattens the star schema back to one-row-per-order so the analysis
-- queries in 04_analysis/sql/queries/ (and the deck's Appendix B) can
-- select straight from `orders` without repeating the fact→dim joins.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW orders AS
SELECT DISTINCT
    f.order_id,
    f.customer_id,
    c.customer_name,
    c.customer_country,
    f.employee_id,
    e.employee_name,
    f.shipper_id,
    s.shipper_name,
    f.order_date,
    f.required_date,
    f.shipped_date,
    f.ship_status,
    f.ship_country,
    f.is_late,
    f.is_risk
FROM fact_order_lines f
JOIN dim_customers c ON f.customer_id = c.customer_id
JOIN dim_employees e ON f.employee_id = e.employee_id
JOIN dim_shippers  s ON f.shipper_id  = s.shipper_id;

-- ---------------------------------------------------------------------------
-- FK / row-count sanity checks
-- ---------------------------------------------------------------------------
-- SELECT COUNT(*) FROM fact_order_lines;                       -- expect 2,155
-- SELECT COUNT(DISTINCT order_id) FROM fact_order_lines;        -- expect 830
-- SELECT COUNT(*) FROM dim_customers;                           -- expect 89
-- SELECT COUNT(*) FROM dim_products;                            -- expect 77
-- SELECT COUNT(*) FROM dim_shippers;                            -- expect 3
-- SELECT COUNT(*) FROM dim_employees;                           -- expect 9
-- SELECT COUNT(*) FROM dim_categories;                          -- expect 8
