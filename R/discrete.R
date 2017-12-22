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
#' # Returns the row count per am 
#' mtcars %>%
#'   db_compute_count(am)
#' 
#' # Returns the average mpg per am
#' mtcars %>%
#'   db_compute_count(am, mean(mpg))
#' 
#' @export 
#' @import dplyr
#' @importFrom rlang enexpr 
db_compute_count <- function(data, x, y = n()){
  x <- enexpr(x)
  y <- enexpr(y)
  
  df <- data %>%
    group_by(!! x) %>%
    summarise(result = !! y) %>%
    collect() %>%
    mutate(result = as.numeric(result)) #Accounts for interger64
    
  colnames(df) <- c(x, y)
  
  df
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
dbplot_bar <- function(data, x, y = n()){
  x <- enexpr(x)
  y <- enexpr(y)
  
  df <- db_compute_count(data = data,
                         x = !! x,
                         y = !! y)
  
  colnames(df) <- c("x", "y")
  
  ggplot2::ggplot(df) +
    ggplot2::geom_col(aes(x, y)) +
    ggplot2::labs(x = x,
         y = y)
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
dbplot_line <- function(data, x, y = n()){
  x <- enexpr(x)
  y <- enexpr(y)
  
  df <- db_compute_count(data = data,
                         x = !! x,
                         y = !! y)
  
  colnames(df) <- c("x", "y")
  
  ggplot2::ggplot(df) +
    ggplot2::geom_line(aes(x, y), stat = "identity") +
    ggplot2::labs(x = x,
         y = y)
}




