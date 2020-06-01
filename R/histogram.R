#' Calculates a histogram bins
#'
#' @description
#'
#' Uses very generic dplyr code to create histogram bins.
#' Because of this approach,
#' the calculations automatically run inside the database if `data` has
#' a database or sparklyr connection. The `class()` of such tables
#' in R are: tbl_sql, tbl_dbi, tbl_spark
#'
#' @param data A table (tbl)
#' @param x A continuous variable
#' @param bins Number of bins. Defaults to 30.
#' @param binwidth Single value that sets the side of the bins, it overrides bins
#'
#' @examples
#'
#' # Returns record count for 30 bins in mpg
#' mtcars %>%
#'   db_compute_bins(mpg)
#'
#' # Returns record count for bins of size 10
#' mtcars %>%
#'   db_compute_bins(mpg, binwidth = 10)
#' @seealso
#' \code{\link{db_bin}},
#'
#' @export
db_compute_bins <- function(data, x, bins = 30, binwidth = NULL) {
  x <- enquo(x)

  xf <- db_bin(
    var = !!x,
    bins = bins,
    binwidth = binwidth
  )

  res <- select(data, !!x)
  res <- count(res, !!x := !!xf)
  res <- collect(res)
  res <- ungroup(res)
  rename(res, count = n)
}

#' Histogram
#'
#' @description
#'
#' Uses very generic dplyr code to aggregate data and then `ggplot2`
#' to create the histogram.  Because of this approach,
#' the calculations automatically run inside the database if `data` has
#' a database or sparklyr connection. The `class()` of such tables
#' in R are: tbl_sql, tbl_dbi, tbl_spark
#'
#' @param data A table (tbl)
#' @param x A continuous variable
#' @param bins Number of bins. Defaults to 30.
#' @param binwidth Single value that sets the side of the bins, it overrides bins
#'
#' @examples
#'
#' library(ggplot2)
#' library(dplyr)
#'
#' # A ggplot histogram with 30 bins
#' mtcars %>%
#'   dbplot_histogram(mpg)
#'
#' # A ggplot histogram with bins of size 10
#' mtcars %>%
#'   dbplot_histogram(mpg, binwidth = 10)
#' @seealso
#' \code{\link{dbplot_bar}}, \code{\link{dbplot_line}} ,
#'  \code{\link{dbplot_raster}}
#'
#' @export
dbplot_histogram <- function(data, x, bins = 30, binwidth = NULL) {
  x <- enexpr(x)

  df <- db_compute_bins(
    data = data,
    x = !!x,
    bins = bins,
    binwidth = binwidth
  )
  df <- mutate(
    df,
    x = !!x
  )

  ggplot(df) +
    geom_col(aes(x, count),
             orientation = "x") +
    labs(
      x = quo_name(x),
      y = "count"
    )
}

globalVariables(c("w", "labs"))
