context("dbplots")

test_that("A ggplot2 object is returned", {
  expect_is(dbplot_bar(mtcars, am), "ggplot")
  expect_is(dbplot_bar(mtcars, am, mean(wt)), "ggplot")
  expect_is(dbplot_line(mtcars, am), "ggplot")
  expect_is(dbplot_histogram(mtcars, mpg), "ggplot")
  expect_is(dbplot_raster(mtcars, wt, mpg), "ggplot")
})

test_that("A no warnings or errors are returned", {
  expect_silent(dbplot_bar(mtcars, am))
  expect_silent(dbplot_bar(mtcars, am, mean(wt)))
  expect_silent(dbplot_line(mtcars, am))
  expect_silent(dbplot_histogram(mtcars, mpg))
  expect_silent(dbplot_raster(mtcars, wt, mpg))
})
