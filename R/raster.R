#' Aggregates intersections of two variables
#' 
#' @description 
#' 
#' To visualize two continuous variables, we typically resort to a Scatter plot. However, 
#' this may not be practical when visualizing millions or billions of dots representing the 
#' intersections of the two variables. A Raster plot may be a better option, 
#' because it concentrates the intersections into squares that are easier to parse visually.
#' 
#' Uses very generic dplyr code to aggregate data.  Because of this approach,
#' the calculations automatically run inside the database if `data` has
#' a database or sparklyr connection. The `class()` of such tables
#' in R are: tbl_sql, tbl_dbi, tbl_sql
#' 
#' 
#' @details
#' 
#' There are two considerations when using a Raster plot with a database. Both considerations are related 
#' to the size of the results downloaded from the database:
#' 
#' - The number of bins requested: The higher the bins value is, the more data is downloaded from the database.
#' 
#' - How concentrated the data is: This refers to how many intersections return a value. The more intersections without a value, 
#' the less data is downloaded from the database.
#' 
#' @param data A table (tbl)
#' @param x A continuous variable
#' @param y A continuous variable
#' @param fill The aggregation formula. Defaults to count (n)
#' 
#' @examples 
#' 
#' # Returns a 100x100 grid of record count of intersections of eruptions and waiting
#' faithful %>% 
#'   db_compute_raster(eruptions, waiting)
#' 
#' # Returns a 50x50 grid of eruption averages of intersections of eruptions and waiting
#' faithful %>%
#'   db_compute_raster(eruptions, waiting, fill = mean(eruptions), resolution = 50)
#' 
#' @export
#' @import dplyr
#' @import rlang
db_compute_raster <- function(data, x, y, fill = n(), resolution = 100){
  x <- enexpr(x)
  y <- enexpr(y)
  fillname <- enexpr(fill)
  
  xf <- db_bin(!! x, 
               bins = resolution) 
  
  yf <- db_bin(!! y, 
               bins = resolution) 
  
  df <- data %>%
    group_by(x = !! xf,
             y = !! yf) %>%
    summarise(fill = !! fillname) %>%
    collect 
  
  colnames(df) <- c(x, y, fillname)
  
  df
}


#' Raster plot
#' 
#' @description 
#' 
#' To visualize two continuous variables, we typically resort to a Scatter plot. However, 
#' this may not be practical when visualizing millions or billions of dots representing the 
#' intersections of the two variables. A Raster plot may be a better option, 
#' because it concentrates the intersections into squares that are easier to parse visually.
#' 
#' Uses very generic dplyr code to aggregate data and ggplot2 to create
#' a raster plot.  Because of this approach,
#' the calculations automatically run inside the database if `data` has
#' a database or sparklyr connection. The `class()` of such tables
#' in R are: tbl_sql, tbl_dbi, tbl_sql
#' 
#' @details
#' 
#' There are two considerations when using a Raster plot with a database. Both considerations are related 
#' to the size of the results downloaded from the database:
#' 
#' - The number of bins requested: The higher the bins value is, the more data is downloaded from the database.
#' 
#' - How concentrated the data is: This refers to how many intersections return a value. The more intersections without a value, 
#' the less data is downloaded from the database.
#' 
#' @param data A table (tbl)
#' @param x A continuous variable
#' @param y A continuous variable
#' @param fill The aggregation formula. Defaults to count (n)
#' 
#' @examples 
#' 
#' # Returns a 100x100 raster plot of record count of intersections of eruptions and waiting
#' faithful %>% 
#'   dbplot_raster(eruptions, waiting)
#' 
#' # Returns a 50x50 raster plot of eruption averages of intersections of eruptions and waiting
#' faithful %>%
#'   dbplot_raster(eruptions, waiting, fill = mean(eruptions), resolution = 50)
#' 
#' @seealso 
#' \code{\link{dbplot_bar}}, \code{\link{dbplot_line}} ,
#' \code{\link{dbplot_histogram}}
#' 
#' 
#' @export
#' @import dplyr
#' @import rlang
#' @import ggplot2
dbplot_raster <- function(data, x, y, fill = n(), resolution = 100){
  x <- enexpr(x)
  y <- enexpr(y)
  fillname <- enexpr(fill)
  
  xf <- db_bin(!! x, 
               bins = resolution) 
  
  yf <- db_bin(!! y, 
               bins = resolution) 
  
  df <- data %>%
    group_by(x = !! xf,
             y = !! yf) %>%
    summarise(fill = !! fillname) %>%
    collect 
  
  df %>%
    ggplot() +
    geom_raster(aes(x, y, fill = fill)) +
    labs(x = x,
         y = y) +
    scale_fill_continuous(name = fillname)
}


