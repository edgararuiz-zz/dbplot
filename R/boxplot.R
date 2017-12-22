#' Returns a dataframe with boxplot calculations
#' 
#' @description 
#' 
#' Uses very generic dplyr code to create boxplot calculations.  
#' Because of this approach,
#' the calculations automatically run inside the database if `data` has
#' a database or sparklyr connection. The `class()` of such tables
#' in R are: tbl_sql, tbl_dbi, tbl_spark
#' 
#' It currently only works with Spark and Hive connections.
#' 
#' @param data A table (tbl)
#' @param x A discrete variable in which to group the boxplots
#' @param var A continuous variable 
#' @param coef Length of the whiskers as multiple of IQR. Defaults to 1.5
#' 
#' @export
#' @import dplyr
#' @importFrom rlang enexpr 
db_compute_boxplot <- function(data, x, var, coef = 1.5){
  
  x <- enexpr(x)
  
  var <- enexpr(var)
  
  df <- data %>%
    group_by(!! x) %>%
    summarise(
      lower = percentile_approx(!! var, 0.25),
      middle = percentile_approx(!! var, 0.5),
      upper = percentile_approx(!! var, 0.75),
      max_raw = max(!! var),
      min_raw = min(!! var)
    ) %>%
    mutate(iqr = (upper - lower) * coef) %>%
    mutate(
      min_iqr = lower - iqr,
      max_iqr = upper + iqr
    ) %>%
    mutate(
      ymax = ifelse(max_raw > max_iqr, max_iqr, max_raw),
      ymin = ifelse(min_raw < min_iqr, min_iqr, min_raw)
    ) %>%
    collect()
    
    df
}

#' Boxplot
#' 
#' @description 
#' 
#' Uses very generic dplyr code to aggregate data and then `ggplot2` 
#' to create the boxplot  Because of this approach,
#' the calculations automatically run inside the database if `data` has
#' a database or sparklyr connection. The `class()` of such tables
#' in R are: tbl_sql, tbl_dbi, tbl_spark
#' 
#' It currently only works with Spark and Hive connections.
#' 
#' @param data A table (tbl)
#' @param x A discrete variable in which to group the boxplots
#' @param var A continuous variable 
#' @param coef Length of the whiskers as multiple of IQR. Defaults to 1.5
#' 
#' @seealso 
#' \code{\link{dbplot_bar}}, \code{\link{dbplot_line}} ,
#'  \code{\link{dbplot_raster}}, \code{\link{dbplot_histogram}} 
#' 
#' @export
#' @import dplyr
#' @importFrom rlang enexpr 
dbplot_boxplot <- function(data, x, var, coef = 1.5){
  
  x <- enexpr(x)
  
  var <- enexpr(var)
  
  df <- db_compute_boxplot(
    data = data,
    x = !! x,
    var = !! var,
    coef = coef
  ) 
  
  colnames(df) <- c("x", "lower", "middle", "upper", "max_raw", "min_raw", 
                    "iqr", "min_iqr", "max_iqr", "ymax",   "ymin")
  
  
  ggplot2::ggplot(df) +
    ggplot2::geom_boxplot(
      aes(
        x = x,
        ymin = ymin,
        lower = lower,
        middle = middle,
        upper = upper,
        ymax = ymax
      ), stat = "identity"
    ) +
    ggplot2::labs(x = x)
}

globalVariables(c("upper", "ymax", "weight", "x_", "y", "aes", "ymin", "lower", 
                  "middle", "upper", "iqr", "max_raw", "max_iqr", "min_raw", 
                  "min_iqr", "percentile_approx"))
