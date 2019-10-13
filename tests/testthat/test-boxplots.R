context("boxplots")

test_that("dbplot_boxplot() returns a ggplot", {
  expect_is(dbplot_boxplot(mtcars, am, mpg), "ggplot")
})

test_that("db_compute_boxplot() returns the right number of rows", {
  expect_equal(nrow(db_compute_boxplot(mtcars, am, mpg)), 2)
  expect_equal(nrow(db_compute_boxplot(group_by(mtcars, gear), am, mpg)), 4)
})

test_that("calc_boxplot_mssql() returns the right number of rows", {
  expect_equal(nrow(calc_boxplot_mssql(group_by(mtcars, am), expr(mpg))), 2)
  expect_equal(nrow(calc_boxplot_mssql(group_by(mtcars, am, gear), expr(mpg))), 4)
})

test_that("calc_boxplot_sparklyr() returns the right number of rows", {
  percentile_approx <<- function(x, ...) quantile(x, ...)
  expect_equal(nrow(calc_boxplot_sparklyr(group_by(mtcars, am), expr(mpg))), 2)
  expect_equal(nrow(calc_boxplot_sparklyr(group_by(mtcars, am, gear), expr(mpg))), 4)
})
