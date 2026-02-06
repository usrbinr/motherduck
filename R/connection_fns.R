
#' @title Validate connection is DuckDB
#' @name validate_con
#' @description
#' Validates that your connection object is a DuckDB connection
#'
#' @param .con  A valid `DBI` connection (DuckDB / MotherDuck).
#
#' @returns logical value or error message
#'
#' @examples
#' \dontrun{
#' con <- DBI::dbConnect(duckdb::duckdb())
#' validate_duckdb_con(con)
#' }
validate_con <- function(.con){

    dbIsValid_poss <- purrr::possibly(DBI::dbIsValid)


    valid_test <- is.null(dbIsValid_poss(.con))

    if(valid_test){

        cli::cli_abort("Connection string is not valid, please try again")

    }else{

        return(TRUE)

    }
}



#' @title Validate Mother Duck Connection Status
#' @name validate_md_connection_status
#' @description
#' Validates if you are successfully connected to motherduck database and will return either a logical value or print a message
#'
#'
#' @inheritParams validate_con
#' @param return_type return message or logical value of connection status
#' @seealso [connect_to_motherduck()]
#'
#' @returns logical value or warning message
#' @export
#'
#' @examples
#' \dontrun{
#' con <- DBI::dbConnect(duckdb::duckdb())
#' validate_md_connection_status(con)
#' }
validate_md_connection_status <- function(.con,return_type="msg"){

    # return_type <- "msg"
    return_type <- rlang::arg_match(
        return_type
        ,values  = c("msg","arg")
    )

    validate_con(.con)

    dbExectue_safe <- purrr::safely(DBI::dbExecute)

    out <- dbExectue_safe(.con, "PRAGMA MD_CONNECT")

    status_lst <- list()

    if(any(stringr::str_detect(out$error$message,"Error: already connected")==TRUE)){

        status_lst$msg <-  \(x) cli::cli_alert_success("You are connected to MotherDuck")
        status_lst$arg <- TRUE

    }else{


        status_lst$msg <-\(x) cli::cli_alert_warning("You are not connected to MotherDuck")
        status_lst$arg <- FALSE

    }

    if(return_type=="msg"){

        cli::cli_h2(text="Connection Status Report:")
        return(status_lst$msg())

    }else{

        return(status_lst$arg)

    }

}

#' @title Check platform compatibility with MotherDuck
#' @name check_platform
#'
#' @description
#' Internal function that checks if the current platform supports MotherDuck.
#' MotherDuck R extension is not available on Windows.
#'
#' @return Invisibly returns `TRUE` if platform is supported.
#' @keywords internal
#' @noRd
check_platform <- function() {

    if (.Platform$OS.type == "windows") {
        cli::cli_abort(c(
            "MotherDuck is not available on Windows.",
            "i" = "The MotherDuck extension for R does not currently support Windows.",
            "i" = "Use Windows Subsystem for Linux (WSL) as a workaround.",
            "i" = "See: {.url https://motherduck.com/docs/integrations/language-apis-and-drivers/r/}"
        ))
    }

    return(invisible(TRUE))
}


#' @title Check DuckDB version compatibility with MotherDuck
#' @name check_duckdb_version
#'
#' @description
#' Internal function that checks if the installed DuckDB version is compatible
#' with MotherDuck and warns if it's outside the tested range.
#'
#' @details
#' MotherDuck supports DuckDB versions 1.3.0 through 1.4.4 (as of early 2025).
#' This function warns users if they're using an untested version.
#'
#' @return Invisibly returns `TRUE` if version is compatible, `FALSE` otherwise.
#' @keywords internal
#' @noRd
check_duckdb_version <- function() {

    duckdb_version <- utils::packageVersion("duckdb")
    min_version <- package_version("1.3.0")
    max_tested_version <- package_version("1.4.4")

    if (duckdb_version < min_version) {
        cli::cli_abort(c(
            "DuckDB version {.val {duckdb_version}} is too old for MotherDuck.",
            "i" = "MotherDuck requires DuckDB >= 1.3.0.",
            "i" = "Update with: {.code install.packages('duckdb')}"
        ))
    }

    if (duckdb_version > max_tested_version) {
        cli::cli_warn(c(
            "DuckDB version {.val {duckdb_version}} is newer than the tested version ({.val {max_tested_version}}).",
            "i" = "MotherDuck may not be compatible with this version yet.",
            "i" = "If you encounter issues, install a compatible version:",
            "i" = "{.code install.packages('duckdb', repos = 'https://packagemanager.posit.co/cran/2024-12-01')}"
        ))
        return(invisible(FALSE))
    }

    return(invisible(TRUE))
}


#' @title Create connection to motherduck
#' @name  connect_to_motherduck
#'
#' @description
#' Establishes a connection to a MotherDuck account using DuckDB and the MotherDuck extension.
#' The function handles token validation, database file creation, extension loading, and executes
#' `PRAGMA MD_CONNECT` to authenticate the connection.
#'
#' @details
#' This function provides a convenient interface for connecting to MotherDuck. It:
#' * Uses the token from the `MOTHERDUCK_TOKEN` environment variable.
#' * Optionally specifies a persistent DuckDB database file or directory via `db_path`.
#' * Optionally provides custom DuckDB configuration options via `config`.
#' * Automatically loads the MotherDuck extension if not already loaded.
#'
#' You must set the `MOTHERDUCK_TOKEN` environment variable in your `.Renviron` file
#' before calling this function. Use `usethis::edit_r_environ()` to edit your
#' `.Renviron` file.
#'
#' If `db_path` is not supplied, a temporary DuckDB database file will be created in the session's
#' temporary directory. Use `config` to pass any DuckDB-specific options (e.g., memory limits or
#' extensions).
#'
#' MotherDuck currently supports DuckDB versions 1.3.0 through 1.4.4. This function
#' will warn if you're using an untested version.
#'
#' @param db_path Character, optional. Path to a DuckDB database file or directory to use. If
#'   `NULL`, a temporary file is used.
#' @param config List, optional. A list of DuckDB configuration options to be passed to
#'   `duckdb::duckdb()`.
#'
#' @return A `DBIConnection` object connected to your MotherDuck account.
#'
#' @examples
#' \dontrun{
#' # Connect using a token stored in your .Renviron
#' con <- connect_to_motherduck()
#'
#' # Connect and specify a persistent database file
#' con <- connect_to_motherduck(db_path = "~/my_database.duckdb")
#' }
#'
#' @export
connect_to_motherduck <- function(db_path = NULL, config) {

    # Check platform compatibility (Windows not supported)
    check_platform()

    # Check DuckDB version compatibility
    check_duckdb_version()

    # Validate token exists in environment
    token <- Sys.getenv("MOTHERDUCK_TOKEN")

    if (nchar(token) == 0) {
        cli::cli_abort(c(
            "MotherDuck token not found.",
            "i" = "Set {.envvar MOTHERDUCK_TOKEN} in your {.file ~/.Renviron} file.",
            "i" = "Get your token from {.url https://app.motherduck.com} > Settings > Access Tokens.",
            "i" = "Use {.fn usethis::edit_r_environ} to edit your {.file ~/.Renviron} file.",
            "i" = "Add: {.code MOTHERDUCK_TOKEN=your_token_here}"
        ))
    }

    # Confirm config is a list
    if (!missing(config)) {
        assertthat::assert_that(is.list(config))
    }

    # Use provided dbdir or fallback to temp file
    if (is.null(db_path)) {
        db_path <- tempfile(fileext = ".duckdb")
    }

    .con <- DBI::dbConnect(duckdb::duckdb(dbdir = db_path))

    if (!validate_extension_load_status(.con, "motherduck", return_type = "arg")) {
        load_extensions(.con, "motherduck")
    }

    dbExecute_safe <- purrr::safely(DBI::dbExecute)

    if (!missing(config)) {
        sql_statements <- vapply(
            names(config),
            function(x) sprintf("SET %s='%s';", x, config[[x]]),
            character(1)
        )

        for (stmt in sql_statements) {
            dbExecute_safe(.con, stmt)
        }
    }

    # Connect to motherduck
    dbExecute_safe(.con, "PRAGMA MD_CONNECT")

    validate_md_connection_status(.con, return_type = "msg")

    return(.con)
}



#' @title Validate and print your database location
#' @name validate_and_print_database_location
#' @description
#' Internal function to help validate your local database location.
#'
#' @inheritParams validate_con
#'
#' @returns Prints a message with the database file location.
#' @keywords internal
#'
validate_and_print_database_location <- function(.con){

    validate_con(.con)

    file_location <- .con@driver@dbdir

    assertthat::assert_that(
        file.exists(file_location)
        ,msg = cli::format_error("Failed to find file or database at {.file {file_location}}")
    )
    cli::cli_alert_success("created or located a database at {.file {file_location}}")
}
