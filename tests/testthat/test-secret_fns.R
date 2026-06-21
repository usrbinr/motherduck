test_that("is_remote_path detects object-storage URLs", {
    expect_true(is_remote_path("r2://bucket/key.csv"))
    expect_true(is_remote_path("s3://bucket/key.csv"))
    expect_true(is_remote_path("https://example.com/key.csv"))
    expect_true(is_remote_path("GCS://bucket/key.csv"))
    expect_false(is_remote_path("data-raw/key.csv"))
    expect_false(is_remote_path("/home/user/key.csv"))
})

test_that("build_secret_sql emits TYPE, name, quoted values, and drops NULLs", {
    con <- DBI::dbConnect(duckdb::duckdb())
    on.exit(DBI::dbDisconnect(con, shutdown = TRUE))

    sql <- as.character(build_secret_sql(
        con,
        name   = "r2",
        type   = "R2",
        fields = list(KEY_ID = "AKID", SECRET = "shh", ACCOUNT_ID = "acct123", REGION = NULL)
    ))

    expect_match(sql, "CREATE OR REPLACE SECRET")
    expect_match(sql, "TYPE R2")
    expect_match(sql, "SECRET\\s+\"?r2\"?\\s*\\(")  # named secret (quoting optional)
    expect_match(sql, "KEY_ID 'AKID'")        # value as string literal
    expect_match(sql, "ACCOUNT_ID 'acct123'")
    expect_no_match(sql, "REGION")            # NULL field dropped
})

test_that("build_secret_sql honours persistent flag", {
    con <- DBI::dbConnect(duckdb::duckdb())
    on.exit(DBI::dbDisconnect(con, shutdown = TRUE))

    sql <- as.character(build_secret_sql(
        con, name = "r2", type = "R2",
        fields = list(KEY_ID = "AKID", SECRET = "shh", ACCOUNT_ID = "acct123"),
        persistent = TRUE
    ))
    expect_match(sql, "CREATE OR REPLACE PERSISTENT SECRET")
})

test_that("create_r2_secret validates its arguments", {
    con <- DBI::dbConnect(duckdb::duckdb())
    on.exit(DBI::dbDisconnect(con, shutdown = TRUE))

    expect_error(create_r2_secret(con, account_id = "", key_id = "k", secret = "s"))
    expect_error(create_r2_secret(con, account_id = "a", key_id = c("k1", "k2"), secret = "s"))
})
