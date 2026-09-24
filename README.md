# SQL Data Cleaning Project

A MySQL data cleaning project that turns a raw customer orders table into a clean, analysis-ready dataset, using a staging-table workflow so the original data is never modified.

## Overview

Raw data is rarely ready for analysis. This project walks through a typical cleaning pipeline in pure SQL:

1. Create staging tables (protect the raw data)
2. Remove duplicate records
3. Standardize text and date formats
4. Handle blank and NULL values
5. Drop helper columns and validate the result

## Tools

- **MySQL 8+** (window functions and CTEs are required)
- SQL concepts used: `CREATE TABLE ... LIKE`, `ROW_NUMBER() OVER (PARTITION BY ...)`, CTEs, `TRIM()`, `STR_TO_DATE()`, self-joins, `UPDATE ... JOIN`, `ALTER TABLE`

## Dataset

The source table `customers` contains customer order records:

| Column | Description |
|---|---|
| `order_id` | Order identifier |
| `customer_id` | Customer identifier |
| `customer_name` | Customer name |
| `product_id` | Product identifier |
| `product_name` | Product name |
| `category` | Product category |
| `quantity` | Units ordered |
| `unit_price_eur` | Price per unit in EUR |
| `order_date` | Date of the order |
| `city` | Customer city |

## Cleaning Steps

### 1. Staging tables
`customer_staging` is an exact copy of `customers`. All work happens on copies, so the raw table stays untouched and any mistake can be rolled back by re-copying.

### 2. Removing duplicates
`ROW_NUMBER()` is applied over all columns (`PARTITION BY` every field). Any row with `row_num > 1` is an exact duplicate.

MySQL does not allow `DELETE` on a CTE, so the row number is stored in a second staging table (`customer_staging2`) and duplicates are deleted from there.

### 3. Standardizing data
- `TRIM()` removes leading and trailing whitespace from `category`
- `SELECT DISTINCT city` is used to spot inconsistent spellings
- Dates stored as text (`dd/mm/yyyy`) are converted with `STR_TO_DATE()` and the column is changed to the `DATE` type (this step is included in the script as an optional, commented block)

### 4. Null and blank values
- Empty strings are converted to real `NULL` values
- Missing `category` values are filled by self-joining the table on `product_id` and borrowing the category from another row of the same product
- A final check lists any rows that still have no category

### 5. Final cleanup
The helper `row_num` column is dropped, leaving a clean `customer_staging2` table ready for analysis or visualization.

## How to Run

1. Load your raw data into a MySQL table named `customers`.
2. Open `Data_Cleaning.sql` in MySQL Workbench (or any MySQL client).
3. Run the script section by section, checking the preview `SELECT` queries before each `UPDATE` / `DELETE`.
4. The cleaned data is in `customer_staging2`.

> **Tip:** if `order_date` is already a `DATE` column, leave the date conversion block commented out.

## Repository Structure

```
.
├── Data_Cleaning.sql   # Full cleaning script
└── README.md
```

## Key Takeaways

- Always clean a copy of the data, never the raw table
- Preview with `SELECT` before running `UPDATE` or `DELETE`
- Window functions make duplicate detection simple and reliable
- Self-joins can recover missing values from other rows of the same entity

## Author

**Wassim** — [GitHub](https://github.com/wassim-svg)
