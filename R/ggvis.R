#' @export
apply_props.tbl_sql <- function(data, props) {
  cols <- lapply(props, prop_value, data = data)
  colnames(cols) <- vapply(props, prop_label, character(1))
  quickdf(cols)
}

#' @export
prop_type.tbl_sql <- function(data, prop) {
  
  if("tbl_sql" %in% class(data)) {"numeric"}
    else {ggvis::vector_type(ggvis:::prop_value(prop, data))}
    
}


#' @export
eval_vector.tbl_sql <- function(x, f) {
  1L
}


#' @export
preserve_constants.tbl_sql  <- function(input, output) {
  if("tbl_sql" %in% class(input))
  {output}else
  {ggvis:::preserve_constants.data.frame(input, output)}
}

#' @export
to_expr <- function(x = NULL) {
  if(is.null(x)){
    f <- "n()"
  } else {
    f <- as.character(x)[2]
  }
  
  f <- parse_expr(f)
}


#' @export
#' @import dplyr
compute_count.tbl_sql <- function(x, x_var, w_var = NULL) {
  
  data_prep <-  x %>%
    mutate_("x" = x_var)  %>%
    group_by(x)

  if(is.null(w_var)){
    data_prep <- data_prep %>%
      tally()
  }else{
    w_var <- as.character(w_var)[2]
    data_prep <- data_prep %>%
      mutate_(weight = w_var) %>%
      summarise(n = sum(weight))
    }
  
  data_prep %>% 
    mutate(count_ = n,
           x_ = x) %>%
    select(count_,
           x_) %>%
    collect() %>%
    as.data.frame(stringsAsFactors = FALSE)

  
}

#' @export
#' @import dplyr
compute_bin.tbl_sql <- function(x, x_var, w_var = NULL, width = NULL, ...) {
  
  data_prep <- x %>%
    mutate_("x" = x_var) %>%
    db_compute_bins(x, binwidth = width) 
  
  colnames(data_prep) <- c("x_", "count_")
  
  data_width <- data_prep %>%
    arrange(x_)  %>% 
    mutate(w = x_ - lag(x_)) %>%
    filter(!is.na(w)) %>%
    filter(w == min(w)) %>%
    pull() 
  
  data_width <- data_width[1] 
  
  data_prep %>%
    mutate(xmin_ = x_ - (data_width / 2),
           xmax_ = x_ + (data_width / 2),
           width_ = data_width) %>%
    as.data.frame(stringsAsFactors = FALSE)
}


#' @export
#' @import dplyr
compute_boxplot.tbl_sql <- function(x, var = NULL, coef = 1.5){
  
  groups <- group_vars(x)
  
  data_prep <- x %>%
    mutate_("x" = groups,
            "var" = var) %>%
    ungroup() %>%
    db_compute_boxplot(x, var, coef = coef) %>% 
    arrange(x) %>%
    select(x, min_raw, lower, middle, upper, ymax, ymax) %>%
    as.data.frame(stringsAsFactors = FALSE) %>%
    mutate(outlies_ = list(numeric())) 

  
  colnames(data_prep) <- c(groups ,  "min_", "lower_", "median_", "upper_",  "max_",  "outliers_")
  
  data_prep %>%
    group_by_(groups)  
}

#' @export
#' @import dplyr
compute_boxplot_outliers.tbl_sql1 <- function(x) {

  groups <- group_vars(x)
  
  outliers <- data_frame(x_var = "", value_ = 0)
  
  colnames(outliers) <- c(groups, "value_")
  
  outliers
  
}