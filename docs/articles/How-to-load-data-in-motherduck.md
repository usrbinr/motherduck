# How to load data into motherduck

## Introduction

Before we get into how to use the package, lets quickly review the three
things you will need to load data into a database:

**Database name (Catalog Name)**

- This is object that will hold your schemas, tables or views
- Different databases have their own naming convention, in motherduck,
  this is called Catalog

**Schema name**

- This is a fancy name for the location that classifies and organizes
  your tables, functions, procedures, etc

**Table or view name**

- This is the name of the actual table or view that holds your data
- Table can be a physical table of data that persists whereas a view is
  a stored procedures that queries underlying tables when needed

To save or reference data, you need to either fully qualify the name
with `database_name.schema_name.table_name` or you need to be “in” your
database and schema and reference the table name

If you create a local database without creating a table or schema first
then duckdb will assign “temp” and “main” as the default names for your
database and schema respectively

> **Note 1: Teminology: Duckdb vs. Motherduck**
>
> While not technically a correct explanation; motherduck is a cloud
> based deployment of duckdb where you can have multiple databases,
> control access / permissions, and scale compute / storage as needed
>
> Duckdb is a essentially a single database instance in your local
> computer where you can save the database to a file or create it in
> memory.
>
> Through out these write ups, I tend to use duckdb & motherduck
> interchangeably however all functions in this package will work with a
> motherduck database but some will not work with a duckdb database.
>
> If you are using a local duckdb database you can leave the database
> argument blank.

Later on we will show examples of how to read data from a source files
in csv or excel format directly into motherduck without loading the data
into local memory but for now let’s assume you want to upload some data
that you already have loaded in your R environment

First let us connect to our motherduck database

See the [How to connect to motherduck
vignette](https://usrbinr.github.io/motherduck/articles/How-to-connect-to-motherduck.html)
for more information

> **Caution 1: connect-to-motherduck**
>
> One limitation of connecting to motherduck from R is that you first
> need to create a local duckdb instance which then allows the
> connection to motherduck.
>
> This means you have access to both local (temporary) duckdb database
> and your cloud based motherduck databases.
>
> Check which database you are “in” with the
> [`pwd()`](https://usrbinr.github.io/motherduck/reference/pwd.md)
> command and then use
> [`cd()`](https://usrbinr.github.io/motherduck/reference/cd.md) to
> change to your motherduck databases.

``` r
con_md <- motherduck::connect_to_motherduck(motherduck_token = "MOTHERDUCK_TOKEN") 
```

You will get a message that prints out that actions the package took and
information about your connection

Before uploading new data, it can be helpful to check “where” you are in
your database

You can do this with the
[`pwd()`](https://usrbinr.github.io/motherduck/reference/pwd.md)
function that will print out the current database & schema that you are
in.

``` r
motherduck::pwd(con_md)
```

This would be the default location that you save your database unless
you clarified a different database and schema

By default, you will be in your local duckdb database even though you
are connected to motherduck

See [Caution 1](#cau-con) to understand why we start in a local database
vs. motherduck

To access your motherduck database, you will need to use
[`cd()`](https://usrbinr.github.io/motherduck/reference/cd.md) and
reference the database to navigate in. This will print your current role
and user name, a summary of the schemas and tables that you have access
to as well as summarizes your shares

``` r
motherduck::cd(con_md,database = "contoso")
```

We am now in motherduck database that hosts the data behind the
[contoso](https://usrbinr.github.io/contoso/) package.

Any reference to a schema or table would be relative to this database

We can see what schemas and tables we have access to with our current
database
[`list_current_schemas()`](https://usrbinr.github.io/motherduck/reference/list_current_schemas.md)
or we can look across all databases with
[`list_all_tables()`](https://usrbinr.github.io/motherduck/reference/list_all_tables.md)

You can see more with the [list\_\* family of
functions](https://usrbinr.github.io/motherduck/reference/index.html)

``` r
list_current_schemas(con_md)
```

Now that we know how to navigate to our various database, lets finally
load some existing data into a new database

[`create_table()`](https://usrbinr.github.io/motherduck/reference/create_table.md)
function will create a new database / schema and then will load the data
into a table

``` r
ggplot2::diamonds |>  
    create_table(
        .con = con_md 
        ,database_name = "vignette" 
        ,schema_name = "raw" 
        ,table_name = "diamonds" 
        ,write_type="overwrite"  
        )
```

- Pass your data into the function
- List your motherduck connection
- database name (either new or existing)
- schema name (either new or existing)
- table name
- Either overwrite or append the data

Notice that we don’t assign this object to anything, this just silently
writes our data to our database and prints a message confirming the
performed actions as well as some summary of catalogs, schemas, tables
and shares that you haves access

To validate the data is in our database, we can do the following:

We can validate if we have successfully saved the table in our database
by running
[`list_all_tables()`](https://usrbinr.github.io/motherduck/reference/list_all_tables.md)

Alternatively, you can access your motherduck data by passing your
connection string to
[`dplyr::tbl()`](https://dplyr.tidyverse.org/reference/tbl.html) or
[`DBI::dbGetQuery()`](https://dbi.r-dbi.org/reference/dbGetQuery.html)
with your table reference

## Organizing our data

Let’s say we want to filter and summarize this table and save it to our
database with a new table name – no problem, we can repeat the steps and
this time we will upload a DBI object instead of tibble

``` r
id_name <- DBI::Id("vignette","raw","diamonds") 

diamonds_summary_tbl <- dplyr::tbl(con_md,id_name) |>  
    dplyr::summarise(
        .by=c(color,cut,clarity)
        ,mean_price=mean(price,na.rm=TRUE)
    )


diamonds_summary_tbl |> 
    create_table(   
    .con = con_md
    ,database_name = "vignette"
    ,schema_name = "raw"
    ,table_name = "diamonds_summary" 
    ,write_type = "overwrite"
)
```

While its the same syntax,
[`create_table()`](https://usrbinr.github.io/motherduck/reference/create_table.md)
will work with an R object, duckplyr or DBI object to save that table
into your database

## Create new schema

Let’s say we want to organize these existing tables into a different
schema, we can do this by first creating a new schema and then moving
that table or alternatively loading a table directly with a new schema
and table

``` r
    create_schema(
        .con=con_md
        ,database_name = "vignette"
        ,schema_name = "curated"
    )
```

This will create a new schema if it doesn’t exist but won’t load any
data

``` r
list_current_schemas(con_md)
```

We can copy one of a series of tables to our new schema with
[`copy_tables_to_new_location()`](https://usrbinr.github.io/motherduck/reference/copy_tables_to_new_location.md)

This accepts a tibble or DBI object of objects with table_catalog,
table_schema, table_name headers and will copy them into your new
location

``` r
list_all_tables(con_md) |> 
  dplyr::filter(
    table_catalog=="vignette"
  ) |> 
  copy_tables_to_new_location(
    .con = con_md
    ,from_table_names = _
    ,to_database_name = "vignette"
    ,to_schema_name = "curated"
    )
```

## Drop databaes, schemas or tables

Sometimes we need to delete databases, schema or tables

> Be careful when you do this as its irreversible – there is no CTRL+Z
> to undo this

``` r
delete_schema(con_md,database_name = "vignette",schema_name = "curated",cascade = TRUE)
```

## How to load data directly into motherduck

For csv files, use
the[`read_csv()`](https://usrbinr.github.io/motherduck/reference/read_csv.md)
to directly read a csv file or a series of csv files into your duckdb or
motherduck database

This will read the files from their source location directly into your
database without loading the files into memory which is helpful when you
are dealing with larger than memory data

Underneath the hood, we are using duckdb’s native
[read_csv_auto](https://duckdb.org/docs/stable/data/csv/auto_detection)
function to read the data

You can call pass through addition parameters as listed in
[`motherduck::config_csv`](https://usrbinr.github.io/motherduck/reference/config_csv.md)
list

``` r
write.csv(mtcars,"mtcars.csv")

# cd(schema = "raw")

read_csv(con = con_md,file_path =  "mtcars.csv",to_table_name = "mtcars",header = TRUE)
```

For excel files we can leverage
[`read_excel()`](https://usrbinr.github.io/motherduck/reference/read_excel.md)

Under the hood this code leverages [excel duckdb
extensions](https://duckdb.org/docs/stable/core_extensions/excel) to
read excel files

You can view the configuration options with
[`motherduck::config_excel`](https://usrbinr.github.io/motherduck/reference/config_excel.md)

``` r
openxlsx::write.xlsx(dplyr::starwars,"starwars.xlsx") 

read_excel(
    .con=con_md 
    ,to_database_name = "vignette" 
    ,to_schema_name = "main" 
    ,to_table_name = "starwars" 
    ,file_path = "starwars.xlsx" 
    ,header = TRUE 
    ,sheet = "Sheet 1" 
    ,all_varchar  = TRUE 
    ,write_type = "overwrite"  
)
```
