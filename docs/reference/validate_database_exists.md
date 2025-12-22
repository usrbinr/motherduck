# Check if a Database Exists

Checks whether a database with the specified name exists on the current
connection.

## Usage

``` r
validate_database_exists(.con, database_name)
```

## Arguments

- .con:

  A valid `DBI` connection (DuckDB / MotherDuck).

- database_name:

  A string specifying the database name to check.

## Value

Logical `TRUE` if the database exists, `FALSE` otherwise.

## Details

This function queries the available databases for the connection using
[`motherduck::list_all_databases()`](https://usrbinr.github.io/motherduck/reference/list_all_databases.md)
and performs an exact match check. Returns `TRUE` if the database
exists, `FALSE` otherwise.

## Examples

``` r
if (FALSE) { # \dontrun{
con <- DBI::dbConnect(duckdb::duckdb())
validate_database_exists(con, "test_db")
} # }
```
