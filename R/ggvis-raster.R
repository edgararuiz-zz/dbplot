#' @export
compute_raster <- function(x, x_var, y_var, fill = NULL, res = 50, intersects = 0){
  UseMethod("compute_raster")
}

#' @export
#' @import rlang
#' @import dplyr
compute_raster.default <- function(x, x_var, y_var, fill = NULL, res = 50, intersects = 0){

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
compute_raster.ggvis <- function(x, x_var, y_var, fill = NULL, res = 50, intersects = 0) {
  args <- list(x_var = x_var,
               y_var = y_var,
               fill = fill,
               res = res,
               intersects = intersects)
  
  ggvis:::register_computation(x, args, "rect", function(data, args) {
    output <- ggvis:::do_call(compute_raster, quote(data), .args = args)
    ggvis:::preserve_constants(data, output)
  })
}

#' @export
layer_raster <- function(vis, ..., fill = NULL, res = 50, intersects = 0) {
  
  
  new_props <- ggvis:::merge_props(ggvis:::cur_props(vis), ggvis:::props(...))
  
  x_var <- ggvis:::find_prop_var(new_props, "x.update")
  vis <- ggvis:::set_scale_label(vis, "x", ggvis:::prop_label(ggvis:::cur_props(vis)$x.update))
  
  
  y_var <- ggvis:::find_prop_var(new_props, "y.update")
  vis <- ggvis:::set_scale_label(vis, "y", ggvis:::prop_label(ggvis:::cur_props(vis)$y.update))
  
  vis <- ggvis:::set_scale_label(vis, "fill", "Frequency")
  
  vis <- ggvis:::layer_f(vis, function(v) {
    v <- ggvis:::add_props(v, .props = new_props)
    v <- compute_raster(v, x_var, y_var, fill, res, intersects)
    
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
