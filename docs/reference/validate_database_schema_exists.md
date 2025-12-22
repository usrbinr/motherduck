# Check if a Schema Exists in a Database

Checks whether a schema with the specified name exists within a given
database.

## Usage

``` r
validate_database_schema_exists(.con, database_name, schema_name)
```

## Arguments

- .con:

  A valid `DBI` connection (DuckDB / MotherDuck).

- database_name:

  The database name to check.

- schema_name:

  The schema name to check within the database.

## Value

Logical `TRUE` if the schema exists, `FALSE` otherwise.

## Details

This function queries all tables in the connection using
[`motherduck::list_all_tables()`](https://usrbinr.github.io/motherduck/reference/list_all_tables.md),
filters by `table_catalog` (database), and performs an exact match on
the schema name.

## Examples

``` r
if (FALSE) { # \dontrun{
con <- DBI::dbConnect(duckdb::duckdb())
validate_database_schema_exists(con, "test_db", "main")
} # }
```
