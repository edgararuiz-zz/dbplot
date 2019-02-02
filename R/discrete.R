#' Aggregates over a discrete field
#'
#' @description
#'
#' Uses very generic dplyr code to aggregate data.  Because of this approach,
#' the calculations automatically run inside the database if `data` has
#' a database or sparklyr connection. The `class()` of such tables
#' in R are: tbl_sql, tbl_dbi, tbl_sql
#'
#' @param data A table (tbl)
#' @param x A discrete variable
#' @param ... A set of named or unamed aggregations
#' @param y The aggregation formula. Defaults to count (n)
#'
#' @examples
#' 
#' library(dplyr)
#' 
#' # Returns the row count per am
#' mtcars %>%
#'   db_compute_count(am)
#' 
#' # Returns the average mpg per am
#' mtcars %>%
#'   db_compute_count(am, mean(mpg))
#' 
#' # Returns the average and sum of mpg per am
#' mtcars %>%
#'   db_compute_count(am, mean(mpg), sum(mpg))
#' @export
db_compute_count <- function(data, x, ..., y = n()) {
  x <- enquo(x)
  y <- enquo(y)
  vars <- enquos(...)

  if (length(vars) > 0) {
    sums <- vars
  } else {
    sums <- y
  }

  res <- group_by(data, !!x)
  res <- summarise(res, !!!sums)
  res <- collect(res)
  ungroup(res)
}

#' Bar plot
#'
#' @description
#'
#' Uses very generic dplyr code to aggregate data and then `ggplot2`
#' to create the plot.  Because of this approach,
#' the calculations automatically run inside the database if `data` has
#' a database or sparklyr connection. The `class()` of such tables
#' in R are: tbl_sql, tbl_dbi, tbl_spark
#'
#' @param data A table (tbl)
#' @param x A discrete variable
#' @param ... A set of named or unamed aggregations
#' @param y The aggregation formula. Defaults to count (n)
#'
#' @examples
#' 
#' library(ggplot2)
#' library(dplyr)
#' 
#' # Returns a plot of the row count per am
#' mtcars %>%
#'   dbplot_bar(am)
#' 
#' # Returns a plot of the average mpg per am
#' mtcars %>%
#'   dbplot_bar(am, mean(mpg))
#' 
#' # Returns the average and sum of mpg per am
#' mtcars %>%
#'   dbplot_bar(am, avg_mpg = mean(mpg), sum_mpg = sum(mpg))
#' @seealso
#' \code{\link{dbplot_line}} ,
#' \code{\link{dbplot_histogram}},  \code{\link{dbplot_raster}}
#'
#' @export
dbplot_bar <- function(data, x, ..., y = n()) {
  x <- enquo(x)
  y <- enquo(y)
  vars <- enquos(...)

  df <- db_compute_count(
    data = data, 
    x = !! x,
    !!! vars,
    y = !! y
  )

  if (ncol(df) == 2) {
    if (length(vars) == 1) {
      y <- vars
      ny <- names(y)
    } else {
      ny <- y
    }
    colnames(df) <- c("x", "y")
    output <- ggplot(df) +
      geom_col(aes(x, y)) +
      labs(x = x, y = ny)
  }

  if (ncol(df) > 2) {
    res <- select(df, -!!x)
    output <- imap(
      res,
      ~ {
        df <- tibble(
          x = pull(select(df, !!x)),
          y = .x
        )
        ggplot(df) +
          geom_col(aes(x, y)) +
          labs(x = quo_name(x), y = .y)
      }
    )
  }

  output
}

#' Bar plot
#'
#' @description
#'
#' Uses very generic dplyr code to aggregate data and then `ggplot2`
#' to create a line plot.  Because of this approach,
#' the calculations automatically run inside the database if `data` has
#' a database or sparklyr connection. The `class()` of such tables
#' in R are: tbl_sql, tbl_dbi, tbl_spark
#'
#' If multiple named aggregations are passed, `dbplot` will only use one
#' SQL query to perform all of the operations.  The purpose is to increase
#' efficiency, and only make one "trip" to the database in order to
#' obtains multiple, related, plots.
#'
#' @param data A table (tbl)
#' @param x A discrete variable
#' @param ... A set of named or unamed aggregations
#' @param y The aggregation formula. Defaults to count (n)
#'
#' @examples
#' 
#' library(ggplot2)
#' library(dplyr)
#' 
#' # Returns a plot of the row count per cyl
#' mtcars %>%
#'   dbplot_line(cyl)
#' 
#' # Returns a plot of the average mpg per cyl
#' mtcars %>%
#'   dbplot_line(cyl, mean(mpg))
#' 
#' # Returns the average and sum of mpg per am
#' mtcars %>%
#'   dbplot_line(am, avg_mpg = mean(mpg), sum_mpg = sum(mpg))
#' @seealso
#' \code{\link{dbplot_bar}},
#' \code{\link{dbplot_histogram}},  \code{\link{dbplot_raster}}
#'
#' @export
dbplot_line <- function(data, x, ..., y = n()) {
  x <- enquo(x)
  y <- enquo(y)
  vars <- enquos(...)

  df <- db_compute_count(
    data = data, 
    x = !! x,
    !!! vars,
    y = !! y
  )

  if (ncol(df) == 2) {
    if (length(vars) == 1) {
      y <- vars
      ny <- names(y)
    } else {
      ny <- y
    }
    colnames(df) <- c("x", "y")
    output <- ggplot(df) +
      geom_line(aes(x, y)) +
      labs(x = x, y = ny)
  }

  if (ncol(df) > 2) {
    res <- select(df, -!!x)
    output <- imap(
      res,
      ~ {
        df <- tibble(
          x = pull(select(df, !!x)),
          y = .x
        )
        ggplot(df) +
          geom_line(aes(x, y)) +
          labs(x = quo_name(x), y = .y)
      }
    )
  }
  output
}
