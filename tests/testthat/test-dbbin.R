context("db_bin")

test_that(
  "Correct binwidth formula is returned",
  expect_equal(
    db_bin(var, binwidth = 10),
    rlang::expr((10 * ifelse(as.integer(floor((var - min(var, na.rm = TRUE)) / 10)) ==
      as.integer((max(var, na.rm = TRUE) - min(var, na.rm = TRUE)) / 10),
    as.integer(floor((var - min(var, na.rm = TRUE)) / 10)) - 1,
    as.integer(floor((var - min(var, na.rm = TRUE)) / 10))
    )) +
      min(var, na.rm = TRUE))
  )
)

test_that(
  "No error or warning when translated to SQL",
  expect_silent(
    dbplyr::translate_sql(!!db_bin(field), con = dbplyr::simulate_dbi())
  )
)
