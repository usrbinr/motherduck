# Show Information Schema Schemas

List all schemas available in the connected database.

This function queries the `information_schema.schemata` view to return
metadata about schemas that exist in the database associated with the
provided DBI connection. It is intended for inspection and debugging
purposes and does not modify database state.

## Usage

``` r
show_information_schema(.con)
```

## Arguments

- .con:

  A valid `DBI` connection (DuckDB / MotherDuck).

## Value

A tibble with one row per schema. Columns typically include catalog
name, schema name, schema owner, and other database-specific metadata as
defined by the SQL information schema.

## Details

The structure and contents of the returned tibble depend on the database
backend. Databases may expose additional or fewer columns in
`information_schema.schemata`.

## Examples

``` r
if (FALSE) { # \dontrun{
library(DBI)
con <- dbConnect(duckdb::duckdb())

show_information_schema(con)

dbDisconnect(con, shutdown = TRUE)
} # }
```
