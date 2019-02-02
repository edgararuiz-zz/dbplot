context("boxplots")

test_that("dbplot_boxplot() returns a ggplot", {
  expect_is(dbplot_boxplot(mtcars, am, mpg), "ggplot")
})

test_that("db_compute_boxplot() returns the right number of rows", {
  expect_equal(
    nrow(db_compute_boxplot(mtcars, am, mpg)), 2
  )
})
