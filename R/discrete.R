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
#' @export
db_compute_count <- function(data, x,...,y = n()) {
  x <- enexpr(x)
  y <- enexpr(y)
  vars <- enexprs(...)
  
  if(length(vars) > 0){
    sums <- vars
  } else {
    sums <- y
  }
  
  data %>%
    group_by(!! x) %>%
    summarise(!!! sums) %>%
    collect() %>%
    ungroup()
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
#' @seealso
#' \code{\link{dbplot_line}} ,
#' \code{\link{dbplot_histogram}},  \code{\link{dbplot_raster}} ,
#'
#'
#' @export
#' @import dplyr
#' @importFrom rlang enexpr

dbplot_bar <- function(data, x,...,y = n()) {
  x <- enexpr(x)
  y <- enexpr(y)
  vars <- exprs(...)
  
  df <- db_compute_count(
    data = data, 
    x = !! x,
    vars  = !!! vars,
    y = !! y
  )
  
  if(ncol(df) == 2){
    if(length(vars)==1) y <- vars
    colnames(df) <- c("x", "y")
    output <- ggplot(df) +
      geom_col(aes(x, y)) +
      labs(x = x, y = y)
  } 
  
  if(ncol(df) > 2){
    output <- df %>%
      select(- !! x) %>%
      imap(~{
        df <- tibble(
          x = pull(select(df, !! x)),
          y =.x) %>%
          ggplot() +
          geom_col(aes(x, y)) +
          labs(x = expr_text(x), y = .y)
      })
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
#' @param data A table (tbl)
#' @param x A discrete variable
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
#' @seealso
#' \code{\link{dbplot_bar}},
#' \code{\link{dbplot_histogram}},  \code{\link{dbplot_raster}}
#'
#'
#' @export
#' @import dplyr
#' @importFrom rlang enexpr
dbplot_line <- function(data, x,...,y = n()) {
  x <- enexpr(x)
  y <- enexpr(y)
  vars <- exprs(...)
  
  df <- db_compute_count(
    data = data, 
    x = !! x,
    vars  = !!! vars,
    y = !! y
  )
  
  if(ncol(df) == 2){
    if(length(vars)==1) y <- vars
    colnames(df) <- c("x", "y")
    output <- ggplot(df) +
      geom_line(aes(x, y)) +
      labs(x = x, y = y)
  } 
  
  if(ncol(df) > 2){
    output <- df %>%
      select(- !! x) %>%
      imap(~{
        df <- tibble(
          x = pull(select(df, !! x)),
          y =.x) %>%
          ggplot() +
          geom_line(aes(x, y)) +
          labs(x = expr_text(x), y = .y)
      })
  } 
  output
}
