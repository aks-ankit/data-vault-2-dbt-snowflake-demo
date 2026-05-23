# Data Vault 2.0 on Snowflake with dbt and AutomateDV

A complete Data Vault 2.0 implementation on Snowflake using [dbt](https://www.getdbt.com/) and [AutomateDV](https://github.com/Datavault-UK/automate-dv). Built on the TPC-H benchmark dataset.

## Architecture

```
TPC-H Source Data (Snowflake_Sample_Data)[CUSTOMER, LINEITEM, NATION, ORDERS, PART, PARTSUPP, REGION, SUPPLIER]
  |
  v
Raw Stage (views) ── raw_orders, raw_inventory, raw_transactions
  |
  v
Staging (views) ── hashing, derived columns, metadata via AutomateDV stage() macro
  |
  v
Raw Vault (incremental)
  ├── Hubs (7) ── customer, order, part, supplier, lineitem, nation, region
  ├── Links (6) ── customer_order, customer_nation, inventory, supplier_nation, etc.
  ├── Satellites (8) ── customer_details, order_details, inventory_details, etc.
  └── T-Links (1) ── transactions
```

## What This Demonstrates

- **Full Data Vault 2.0 pattern**: Hubs, Links, Satellites, and Transactional Links
- **YAML-driven staging**: Hash keys, hashdiffs, and derived columns defined in metadata
- **Incremental loading**: All vault models use incremental materialization
- **Configurable scale**: TPC-H dataset size from SF1 to SF10000 via `tpch_size` variable
- **Airflow-ready**: Supports `load_datetime` and `logical_date` variables for orchestrated runs

## Prerequisites

- Snowflake account with access to `SNOWFLAKE_SAMPLE_DATA`
- dbt >= 1.0.0, < 2.0.0
- Python 3.8+

## Setup

1. Clone the repo:
```bash
git clone https://github.com/YOUR_USERNAME/data-vault-2-dbt-snowflake-demo.git
cd data-vault-2-dbt-snowflake-demo
```

2. Install dependencies:
```bash
pip install dbt-snowflake
dbt deps
```

3. Configure your profile — copy the example and fill in your Snowflake credentials:
```bash
cp profiles.yml.example ~/.dbt/profiles.yml
# Edit ~/.dbt/profiles.yml with your Snowflake account details
```

4. Run the project:
```bash
# Full build (raw stage -> staging -> vault)
dbt run

# Or run by layer
dbt run -s tag:raw
dbt run -s tag:stage
dbt run -s tag:raw_vault
```

## Running with Airflow

Pass date variables for incremental loading:
```bash
dbt run -s +tag:raw_vault --vars '{load_datetime: "2026-01-15 00:00:00", logical_date: "2026-01-15"}'
```

## Project Structure

```
models/
├── raw_stage/        # Source views joining TPC-H tables
├── raw_stage_2/      # Alternate raw layer (materialized tables)
├── stage/            # AutomateDV staging with hashing and derived columns
└── raw_vault/
    ├── hubs/         # 7 hub models
    ├── links/        # 6 link models
    ├── sats/         # 8 satellite models
    └── t_links/      # 1 transactional link
```

## Configuration

Set TPC-H scale factor in `dbt_project.yml`:
```yaml
vars:
  tpch_size: 100  # Options: 1, 10, 100, 1000, 10000
```

## License

See [LICENSE](LICENSE) for details.

---

Built by [dbtvault 2.0 Solutions](https://dbtvault-solutions.tech)
