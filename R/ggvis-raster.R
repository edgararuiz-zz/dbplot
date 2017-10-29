
#' Raster plot
#' 
#' @description 
#' 
#' To visualize two continuous variables, we typically resort to a Scatter plot. However, 
#' this may not be practical when visualizing millions or billions of dots representing the 
#' intersections of the two variables. A Raster plot may be a better option, 
#' because it concentrates the intersections into squares that are easier to parse visually.
#' 
#' This function will work with all data frame types, including tbl_sql
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
#' @param x A table (tbl)
#' @param x_var A continuous variable
#' @param y_var A continuous variable
#' @param fill The aggregation formula. Defaults to count (n)
#' @param res The number of bins created by variable. The highest the number, the more records can be potentially imported from the sourd
#' 
#' @examples 
#' 
#' mtcars %>%
#'   compute_raster(~mpg, ~cyl)
#' 
#' # Also supports aggregate formulas for the fill argument
#' mtcars %>%
#'   compute_raster(~mpg, ~cyl, fill = ~sum(wt))
#' 
#' @export
compute_raster <- function(x, x_var, y_var, fill = NULL, res = 50){
  UseMethod("compute_raster")
}


#' @export
#' @import rlang
#' @import dplyr
compute_raster.default <- function(x, x_var, y_var, fill = NULL, res = 50){

  var_fill <- to_expr(fill)
  
  data_prep <- x %>%
    mutate_("x" = x_var,
            "y" = y_var) %>%
    db_compute_raster(x, y, !! var_fill,resolution = res)

  
  x_width <- get_width(data_prep, x)
  
  y_width <- get_width(data_prep, y)
  
  data_prep <- data_prep %>%
    mutate(x2 = x + x_width,
           y2 = y + y_width)
  
  colnames(data_prep) <- c("x1_", "y1_", "agg_", "x2_", "y2_")
  
  as.data.frame(data_prep, stringsAsFactors = FALSE)
  
}


#' @export
compute_raster.ggvis <- function(x, x_var, y_var, fill = NULL, res = 50) {
  args <- list(x_var = x_var,
               y_var = y_var,
               fill = fill,
               res = res)
  
  ggvis:::register_computation(x, args, "rect", function(data, args) {
    output <- ggvis:::do_call(compute_raster, quote(data), .args = args)
    ggvis:::preserve_constants(data, output)
  })
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
#' This function will work with all data frame types, including tbl_sql
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
#' @param vis Visualization to modify
#' @param ... Visual properties, passed on to props.
#' @param fill The aggregation formula. Defaults to count (n)
#' @param res The number of bins created by variable. The highest the number, the more records can be potentially imported from the sourd
#' 
#' @examples 
#' 
#' library(ggvis)
#' 
#' mtcars %>% 
#'   ggvis(~mpg, ~cyl) %>% 
#'   layer_raster()
#' 
#' # Also supports aggregate formulas for the fill argument
#' mtcars %>%
#'   ggvis(~mpg, ~cyl) %>% 
#'  layer_raster(fill = ~sum(wt))
#' 
#' @export
layer_raster <- function(vis, ..., fill = NULL, res = 50) {
  
  
  new_props <- ggvis:::merge_props(ggvis:::cur_props(vis), ggvis::props(...))
  
  x_var <- ggvis:::find_prop_var(new_props, "x.update")
  vis <- ggvis:::set_scale_label(vis, "x", ggvis:::prop_label(ggvis:::cur_props(vis)$x.update))
  
  
  y_var <- ggvis:::find_prop_var(new_props, "y.update")
  vis <- ggvis:::set_scale_label(vis, "y", ggvis:::prop_label(ggvis:::cur_props(vis)$y.update))
  
  
  if(is.null(fill)){
    legend_label <- "Frequency"
  } else {
    legend_label <- as.character(fill)[2]
  }
  
  vis <- ggvis:::set_scale_label(vis, "fill", legend_label)
  
  vis <- ggvis::layer_f(vis, function(v) {
    v <- ggvis::add_props(v, .props = new_props)
    v <- compute_raster(v, x_var, y_var, fill, res)
    
    v <- layer_rects(v, x = ~x1_, x2 = ~x2_ , y = ~y1_, y2 = ~y2_, fill = ~agg_)
    
    v
  })
  vis
}

get_width <- function(data, var){
  
  var <- enexpr(var)
  
  result <- data %>%
    group_by(!! var) %>%
    arrange(!! var) %>%
    tally() %>%
    mutate(lag_var = lag(!! var)) %>%
    mutate(w = -(lag_var) + !! var) %>%
    filter(!is.na(w)) %>%
    filter(w == min(w)) %>%
    pull()
  
  result[1]
}

globalVariables(c("layer_rects", "lag_var"))
