context("discrete")

test_that("Multiple aggregations are supported", {
  expect_equal(
    ncol(db_compute_count(mtcars,
      am,
      sum_wt = sum(wt),
      sum_mpg = sum(mpg)
    )),
    3
  )
})

test_that("Multiple aggregations work with bar plots", {
  x <- dbplot_bar(mtcars,
    am,
    sum_wt = sum(wt), sum_mpg = sum(mpg)
  )
  expect_is(x, "list")
  expect_is(x[[1]], "ggplot")
})

test_that("Multiple aggregations work with line plots", {
  x <- dbplot_line(mtcars,
    am,
    sum_wt = sum(wt), sum_mpg = sum(mpg)
  )
  expect_is(x, "list")
  expect_is(x[[1]], "ggplot")
})
