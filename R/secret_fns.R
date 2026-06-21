#' Build the SQL for a DuckDB/MotherDuck secret
#'
#' @description
#' Internal helper that assembles a `CREATE OR REPLACE SECRET` statement from a
#' named list of fields. Keyword fields (e.g. `TYPE`) are emitted verbatim while
#' credential fields are quoted as string literals via [glue::glue_sql()].
#'
#' @param .con A valid `DBI` connection (used for quoting).
#' @param name Secret name (identifier).
#' @param type Secret type keyword, e.g. `"R2"` or `"S3"`.
#' @param fields Named list of `FIELD = value` pairs. Values are quoted as string
#'   literals; `NULL` entries are dropped.
#' @param persistent Logical; if `TRUE` create a `PERSISTENT` secret.
#' @returns A `glue`/`SQL` string.
#' @keywords internal
build_secret_sql <- function(.con, name, type, fields, persistent = FALSE) {
    keep <- fields[!vapply(fields, is.null, logical(1))]
    field_sql <- purrr::imap_chr(
        keep,
        \(value, key) glue::glue_sql("{DBI::SQL(key)} {value}", .con = .con)
    )
    scope <- if (isTRUE(persistent)) "PERSISTENT " else ""
    glue::glue_sql(
        "CREATE OR REPLACE {DBI::SQL(scope)}SECRET {`name`} (
           TYPE {DBI::SQL(type)},
           {DBI::SQL(paste(field_sql, collapse = ',\n           '))}
         );",
        .con = .con
    )
}

#' Register a Cloudflare R2 secret on a connection
#'
#' @description
#' Creates (or replaces) a DuckDB/MotherDuck secret of `TYPE R2` so subsequent
#' reads from `r2://` paths authenticate against your Cloudflare R2 bucket. R2 is
#' S3-compatible; this is a convenience wrapper over the generic
#' [create_s3_secret()] that derives the endpoint from your account id.
#'
#' @details
#' Requires the `httpfs` extension (load it first with
#' `load_extensions(.con, "httpfs")`). The secret is session-scoped by default;
#' pass `persistent = TRUE` to persist it to the local secret store. On
#' MotherDuck the secret lives in the active session and is used by the cloud
#' engine to fetch the objects.
#'
#' @param .con A valid `DBI` connection (DuckDB / MotherDuck).
#' @param account_id Cloudflare R2 account id (the 32-character hex id).
#' @param key_id R2 S3 access key id.
#' @param secret R2 S3 secret access key.
#' @param name Secret name. Defaults to `"r2"`.
#' @param persistent Logical; persist the secret to the local store. Defaults to
#'   `FALSE` (session-scoped).
#'
#' @returns Invisibly, the secret `name`.
#' @seealso [create_s3_secret()], [load_extensions()]
#' @family db-manage
#' @export
#'
#' @examples
#' \dontrun{
#' con <- connect_to_motherduck()
#' load_extensions(con, "httpfs")
#' create_r2_secret(
#'   con,
#'   account_id = Sys.getenv("R2_ACCOUNT_ID"),
#'   key_id     = Sys.getenv("AWS_ACCESS_KEY_ID"),
#'   secret     = Sys.getenv("AWS_SECRET_ACCESS_KEY")
#' )
#' DBI::dbGetQuery(con, "SELECT * FROM read_csv_auto('r2://my-bucket/data.csv')")
#' }
create_r2_secret <- function(.con, account_id, key_id, secret,
                             name = "r2", persistent = FALSE) {
    validate_con(.con)
    assertthat::assert_that(is.character(account_id), length(account_id) == 1, nzchar(account_id))
    assertthat::assert_that(is.character(key_id), length(key_id) == 1, nzchar(key_id))
    assertthat::assert_that(is.character(secret), length(secret) == 1, nzchar(secret))

    sql <- build_secret_sql(
        .con,
        name       = name,
        type       = "R2",
        fields     = list(KEY_ID = key_id, SECRET = secret, ACCOUNT_ID = account_id),
        persistent = persistent
    )
    DBI::dbExecute(.con, sql)
    cli::cli_alert_success("Created R2 secret {.val {name}}")
    invisible(name)
}

#' Register a generic S3 (S3-compatible) secret on a connection
#'
#' @description
#' Creates (or replaces) a DuckDB/MotherDuck secret of `TYPE S3` for AWS S3 or any
#' S3-compatible object store (Cloudflare R2, MinIO, Backblaze B2, etc.). For
#' Cloudflare R2 prefer the [create_r2_secret()] shortcut.
#'
#' @details
#' Requires the `httpfs` extension. Optional fields (`endpoint`, `region`,
#' `url_style`, `use_ssl`) are only emitted when supplied, so the same helper
#' covers AWS (region only) and self-hosted stores (custom endpoint +
#' `url_style = "path"`).
#'
#' @inheritParams create_r2_secret
#' @param endpoint Optional host of the S3-compatible endpoint, e.g.
#'   `"<account>.r2.cloudflarestorage.com"`. Omit for AWS S3.
#' @param region Optional region, e.g. `"us-east-1"`. R2 ignores this.
#' @param url_style Optional `"path"` or `"vhost"`. S3-compatible stores usually
#'   need `"path"`.
#' @param use_ssl Optional logical; use HTTPS. Defaults to `NULL` (engine default).
#' @param name Secret name. Defaults to `"s3"`.
#'
#' @returns Invisibly, the secret `name`.
#' @seealso [create_r2_secret()], [load_extensions()]
#' @family db-manage
#' @export
#'
#' @examples
#' \dontrun{
#' con <- connect_to_motherduck()
#' load_extensions(con, "httpfs")
#' create_s3_secret(con, key_id = "AKIA...", secret = "...", region = "us-east-1")
#' }
create_s3_secret <- function(.con, key_id, secret, endpoint = NULL, region = NULL,
                             url_style = NULL, use_ssl = NULL,
                             name = "s3", persistent = FALSE) {
    validate_con(.con)
    assertthat::assert_that(is.character(key_id), length(key_id) == 1, nzchar(key_id))
    assertthat::assert_that(is.character(secret), length(secret) == 1, nzchar(secret))

    sql <- build_secret_sql(
        .con,
        name   = name,
        type   = "S3",
        fields = list(
            KEY_ID    = key_id,
            SECRET    = secret,
            ENDPOINT  = endpoint,
            REGION    = region,
            URL_STYLE = url_style,
            USE_SSL   = if (is.null(use_ssl)) NULL else DBI::SQL(tolower(as.character(isTRUE(use_ssl))))
        ),
        persistent = persistent
    )
    DBI::dbExecute(.con, sql)
    cli::cli_alert_success("Created S3 secret {.val {name}}")
    invisible(name)
}
