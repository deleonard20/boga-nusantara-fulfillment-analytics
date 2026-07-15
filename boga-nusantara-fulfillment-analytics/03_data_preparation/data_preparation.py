"""
Boga Nusantara — Order Fulfillment & Revenue Risk Analysis
Data Preparation

Takes the raw denormalized source export (one row per order line, 44 columns)
and:
  1. Splits it into a star schema (1 fact table + 5 dimension tables) written
     to data/raw/*.csv, matching 04_analysis/sql/schema/01_create_tables.sql.
  2. Adds two derived flags used throughout the analysis: is_late and is_risk.
  3. Runs the same order-level dedup logic used everywhere downstream, so
     order counts (830) are never accidentally inflated by line-item counts
     (2,155).

Usage:
    python data_preparation.py --source path/to/source_export.xlsx

Source dataset note: the raw export is a Northwind-style B2B order/shipment
table (customers, products, categories, shippers, employees), reframed under
the Boga Nusantara identity for this case study — see 02_data_discovery/
data_dictionary.md for full column definitions and 01_define/business_brief.md
for the "why" behind this dataset choice.
"""

import argparse
from pathlib import Path

import pandas as pd

OUTPUT_DIR = Path(__file__).resolve().parent.parent / "data" / "raw"

FACT_COLUMNS = [
    "order_id", "product_id", "customer_id", "employee_id", "shipper_id",
    "order_date", "required_date", "shipped_date", "ship_status",
    "ship_city", "ship_region", "ship_postal_code", "ship_country",
    "trx_unit_price", "quantity", "discount", "discount_pct",
    "net_sales", "freight_alloc", "sales_plus_freight",
]


def load_source(path: Path) -> pd.DataFrame:
    df = pd.read_excel(path, sheet_name="dataset")
    n_rows, n_cols = df.shape
    assert n_cols == 44, f"expected 44 source columns, got {n_cols}"
    print(f"Loaded {n_rows:,} order-line rows x {n_cols} columns from {path.name}")
    return df


def add_derived_flags(df: pd.DataFrame) -> pd.DataFrame:
    """is_late / is_risk are the two flags every downstream query relies on.

    is_late  -> ship_status == 'Late'                (confirmed SLA failure)
    is_risk  -> ship_status IN ('Late', 'Pending')    (not confirmed on-time)

    Note: 'Pending' is NOT the same thing as 'Late'. Every Pending order in
    this dataset has a required_date that is still in the future relative to
    the most recent shipped_date in the whole dataset — i.e. Pending simply
    means "hasn't reached its due date yet", not "stuck / overdue". Treating
    Pending as an equal failure to Late would manufacture a fake seasonal
    spike in the most recent month purely from right-censoring. is_risk keeps
    both for headline "not confirmed on-time" reporting; is_late is the
    correct flag for any root-cause / driver analysis.
    """
    df = df.copy()
    df["is_late"] = (df["ship_status"] == "Late").astype(int)
    df["is_risk"] = df["ship_status"].isin(["Late", "Pending"]).astype(int)
    return df


def build_star_schema(df: pd.DataFrame) -> dict[str, pd.DataFrame]:
    dim_categories = (
        df[["category_id", "category_name"]]
        .drop_duplicates()
        .sort_values("category_id")
        .reset_index(drop=True)
    )
    dim_products = (
        df[["product_id", "product_name", "category_id", "catalog_unit_price", "price_band"]]
        .drop_duplicates(subset=["product_id"])
        .sort_values("product_id")
        .reset_index(drop=True)
    )
    dim_shippers = (
        df[["shipper_id", "shipper_name"]]
        .drop_duplicates()
        .sort_values("shipper_id")
        .reset_index(drop=True)
    )
    dim_employees = (
        df[["employee_id", "employee_name", "employee_title", "employee_city", "employee_country"]]
        .drop_duplicates(subset=["employee_id"])
        .sort_values("employee_id")
        .reset_index(drop=True)
    )
    dim_customers = (
        df[["customer_id", "customer_name", "customer_contact", "customer_city",
            "customer_region", "customer_postal_code", "customer_country"]]
        .drop_duplicates(subset=["customer_id"])
        .sort_values("customer_id")
        .reset_index(drop=True)
    )
    fact_order_lines = df[FACT_COLUMNS + ["is_late", "is_risk"]].copy()

    return {
        "dim_categories.csv": dim_categories,
        "dim_products.csv": dim_products,
        "dim_shippers.csv": dim_shippers,
        "dim_employees.csv": dim_employees,
        "dim_customers.csv": dim_customers,
        "fact_order_lines.csv": fact_order_lines,
    }


def order_level_view(df: pd.DataFrame) -> pd.DataFrame:
    """Dedup line items down to one row per order_id.

    Every downstream "% of orders" statistic (93.0% on-time, carrier late
    rate, regional severity, etc.) is computed on THIS table, not on the
    2,155-row line-item table — otherwise multi-line orders would be
    counted multiple times and silently skew every rate calculation.
    """
    order_cols = [
        "order_id", "customer_id", "employee_id", "shipper_id",
        "order_date", "required_date", "shipped_date", "ship_status",
        "ship_country", "customer_name", "employee_name", "shipper_name",
        "is_late", "is_risk",
    ]
    present = [c for c in order_cols if c in df.columns]
    orders = df[present].drop_duplicates(subset=["order_id"]).reset_index(drop=True)
    return orders


def run_sanity_checks(tables: dict[str, pd.DataFrame], orders: pd.DataFrame) -> None:
    fact = tables["fact_order_lines.csv"]
    assert len(fact) == 2155, f"expected 2,155 fact rows, got {len(fact)}"
    assert len(orders) == 830, f"expected 830 distinct orders, got {len(orders)}"
    assert len(tables["dim_customers.csv"]) == 89
    assert len(tables["dim_shippers.csv"]) == 3
    assert len(tables["dim_categories.csv"]) == 8

    on_time_pct = round((orders["ship_status"] == "On time").mean() * 100, 2)
    print(f"Sanity check — on-time rate at order level: {on_time_pct}% (expected 93.01%)")
    print("All checks passed.")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--source",
        default="../../Data BI.xlsx",
        help="Path to the raw source Excel export (default: ../../Data BI.xlsx)",
    )
    args = parser.parse_args()

    df = load_source(Path(args.source))
    df = add_derived_flags(df)

    tables = build_star_schema(df)
    orders = order_level_view(df)
    run_sanity_checks(tables, orders)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    for filename, table in tables.items():
        out_path = OUTPUT_DIR / filename
        table.to_csv(out_path, index=False)
        print(f"  wrote {out_path.relative_to(OUTPUT_DIR.parent.parent)}  ({len(table):,} rows)")


if __name__ == "__main__":
    main()
