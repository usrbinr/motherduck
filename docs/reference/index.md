# Package index

## Connection & Session Management

- [`connect_to_motherduck()`](https://usrbinr.github.io/motherduck/reference/connect_to_motherduck.md)
  : Create connection to motherduck
- [`cd()`](https://usrbinr.github.io/motherduck/reference/cd.md) :
  Change Active Database and Schema
- [`pwd()`](https://usrbinr.github.io/motherduck/reference/pwd.md) :
  Print Current MotherDuck Database Context
- [`validate_con()`](https://usrbinr.github.io/motherduck/reference/validate_con.md)
  : Validate connection is DuckDB
- [`validate_md_connection_status()`](https://usrbinr.github.io/motherduck/reference/validate_md_connection_status.md)
  : Validate Mother Duck Connection Status
- [`show_current_user()`](https://usrbinr.github.io/motherduck/reference/show_current_user.md)
  : Show current database user
- [`show_motherduck_token()`](https://usrbinr.github.io/motherduck/reference/show_motherduck_token.md)
  : Show Your MotherDuck Token
- [`launch_ui()`](https://usrbinr.github.io/motherduck/reference/launch_ui.md)
  : Launch the DuckDB UI in your browser

## Database Management

- [`create_database()`](https://usrbinr.github.io/motherduck/reference/create_database.md)
  : Create (If Not Exists) and Switch to a Database
- [`delete_database()`](https://usrbinr.github.io/motherduck/reference/delete_database.md)
  : Drop a Database
- [`list_all_databases()`](https://usrbinr.github.io/motherduck/reference/list_all_databases.md)
  : List Databases Visible to the Connection
- [`upload_database_to_md()`](https://usrbinr.github.io/motherduck/reference/upload_database_to_md.md)
  : Upload a Local Database to MotherDuck
- [`validate_and_print_database_loction()`](https://usrbinr.github.io/motherduck/reference/validate_and_print_database_loction.md)
  : validate and Pprint your database location

## Schema Management

- [`create_schema()`](https://usrbinr.github.io/motherduck/reference/create_schema.md)
  : Create a Schema in a Database if It Does Not Exist
- [`delete_schema()`](https://usrbinr.github.io/motherduck/reference/delete_schema.md)
  : Drop a Schema from a Database
- [`list_current_schemas()`](https://usrbinr.github.io/motherduck/reference/list_current_schemas.md)
  : List Schemas in the Current Database
- [`alter_table_schema()`](https://usrbinr.github.io/motherduck/reference/alter_table_schema.md)
  : Move Tables from One Schema to Another
- [`copy_tables_to_new_location()`](https://usrbinr.github.io/motherduck/reference/copy_tables_to_new_location.md)
  : Copy Tables to a New Database/Schema
- [`delete_and_create_schema()`](https://usrbinr.github.io/motherduck/reference/delete_and_create_schema.md)
  : Drop and Recreate a Schema in a MotherDuck / DuckDB Database

## Table Management

- [`create_table()`](https://usrbinr.github.io/motherduck/reference/create_table.md)
  : Create or Append a Table from a Tibble or DBI-Backed Table
- [`delete_table()`](https://usrbinr.github.io/motherduck/reference/delete_table.md)
  : Drop a Table
- [`list_all_tables()`](https://usrbinr.github.io/motherduck/reference/list_all_tables.md)
  : List All Tables Visible to the Connection
- [`list_current_tables()`](https://usrbinr.github.io/motherduck/reference/list_current_tables.md)
  : List Tables in the Current Database and Schema

## File Import (CSV, Excel, Parquet)

- [`read_csv()`](https://usrbinr.github.io/motherduck/reference/read_csv.md)
  : Read a CSV file into a DuckDB/MotherDuck table
- [`read_excel()`](https://usrbinr.github.io/motherduck/reference/read_excel.md)
  : Read an Excel file into a DuckDB/MotherDuck table
- [`config_csv`](https://usrbinr.github.io/motherduck/reference/config_csv.md)
  : DuckDB CSV read configuration (config_csv)
- [`config_excel`](https://usrbinr.github.io/motherduck/reference/config_excel.md)
  : DuckDB Excel read configuration (config_excel)
- [`config_parquet`](https://usrbinr.github.io/motherduck/reference/config_parquet.md)
  : DuckDB Parquet read configuration (config_parquet)

## Configuration & Settings

- [`config_db`](https://usrbinr.github.io/motherduck/reference/config_db.md)
  : DuckDB runtime database configuration (config_db)
- [`list_setting()`](https://usrbinr.github.io/motherduck/reference/list_setting.md)
  : List Database Settings
- [`list_fns()`](https://usrbinr.github.io/motherduck/reference/list_fns.md)
  : List Database Functions (DuckDB/MotherDuck)

## Extensions

- [`install_extensions()`](https://usrbinr.github.io/motherduck/reference/install_extensions.md)
  : Install DuckDB/MotherDuck Extensions
- [`load_extensions()`](https://usrbinr.github.io/motherduck/reference/load_extensions.md)
  : Load and Install DuckDB/MotherDuck Extensions
- [`list_extensions()`](https://usrbinr.github.io/motherduck/reference/list_extensions.md)
  : List MotherDuck/DuckDB Extensions
- [`validate_extension_install_status()`](https://usrbinr.github.io/motherduck/reference/validate_extension_install_status.md)
  : Validate Installed MotherDuck/DuckDB Extensions
- [`validate_extension_load_status()`](https://usrbinr.github.io/motherduck/reference/validate_extension_load_status.md)
  : Validate Loaded MotherDuck/DuckDB Extensions

## MotherDuck User & Account Management

- [`create_md_user()`](https://usrbinr.github.io/motherduck/reference/create_md_user.md)
  : Create a new MotherDuck user
- [`delete_md_user()`](https://usrbinr.github.io/motherduck/reference/delete_md_user.md)
  : Delete a MotherDuck user
- [`list_md_active_accounts()`](https://usrbinr.github.io/motherduck/reference/list_md_active_accounts.md)
  : List active MotherDuck accounts
- [`list_md_user_instance()`](https://usrbinr.github.io/motherduck/reference/list_md_user_instance.md)
  : List a MotherDuck user's instance settings
- [`configure_md_user_settings()`](https://usrbinr.github.io/motherduck/reference/configure_md_user_settings.md)
  : Configure a MotherDuck user's settings

## MotherDuck Tokens

- [`create_md_access_token()`](https://usrbinr.github.io/motherduck/reference/create_md_access_token.md)
  : Create a MotherDuck access token
- [`delete_md_access_token()`](https://usrbinr.github.io/motherduck/reference/delete_md_access_token.md)
  : Delete a MotherDuck user's access token
- [`list_md_user_tokens()`](https://usrbinr.github.io/motherduck/reference/list_md_user_tokens.md)
  : List a MotherDuck user's tokens

## MotherDuck Shares

- [`create_if_not_exists_share()`](https://usrbinr.github.io/motherduck/reference/create_if_not_exists_share.md)
  : Create a MotherDuck database share if it does not exist
- [`create_or_replace_share()`](https://usrbinr.github.io/motherduck/reference/create_or_replace_share.md)
  : Create or replace a MotherDuck database share
- [`drop_share()`](https://usrbinr.github.io/motherduck/reference/drop_share.md)
  : Drop a MotherDuck share
- [`describe_share()`](https://usrbinr.github.io/motherduck/reference/describe_share.md)
  : Describe a MotherDuck share
- [`list_shares()`](https://usrbinr.github.io/motherduck/reference/list_shares.md)
  : List MotherDuck Shares
- [`list_owned_shares()`](https://usrbinr.github.io/motherduck/reference/list_owned_shares.md)
  : List all shares owned by the current user
- [`list_shared_with_me_shares()`](https://usrbinr.github.io/motherduck/reference/list_shared_with_me_shares.md)
  : List all shares shared with the current user

## Utilities

- [`validate_and_print_database_loction()`](https://usrbinr.github.io/motherduck/reference/validate_and_print_database_loction.md)
  : validate and Pprint your database location
- [`summary(`*`<tbl_lazy>`*`)`](https://usrbinr.github.io/motherduck/reference/summary.md)
  : Summarize a Lazy DBI Table
