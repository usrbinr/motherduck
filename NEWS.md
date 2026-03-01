# motherduck 0.2.3

* Re-enabled connection validation in `create_schema()` and `delete_and_create_schema()`
* Fixed pkgdown function reference typo for `validate_and_print_database_location()`
* Updated LICENSE year to 2026
* Added installation instructions to README

# motherduck 0.2.2

* Fixed typo in `validate_md_connection_status()` variable name
* Fixed string formatting in error messages for database/schema validation
* Fixed variable bug in `read_csv()` append mode
* Replaced `stop()` with `cli::cli_abort()` for consistent error messaging
* Updated URLs from GitHub to Codeberg
* Added BugReports field to DESCRIPTION
* Various documentation improvements

# motherduck 0.2.1

* minor re-factoring of `create_table()` functions to increase resiliency and robustness
* new meta tools `validate_database_exists()`, `validate_database_schema_exists()` and `show_information_schema()`

# motherduck 0.2.0

* Initial CRAN submission.

# motherduck 0.1.0

* Initial development version
