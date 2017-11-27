#' Bin formula
#' 
#' Uses the rlang package to build the formula needed to create the bins of a numeric variable
#' in an unevaluated fashion.  This way, the formula can be then passed inside a dplyr
#' verb.  
#' 
#' @param var Variable name or formula
#' @param bins Number of bins. Defaults to 30.
#' @param binwidth Single value that sets the side of the bins, it overrides bins
#' 
#' 
#' @examples 
#' 
#'   # Important: Always name the field and
#'   # prefix the function with `!!`` (See Details)
#' 
#'   # Uses the default 30 bins
#'   mtcars %>%
#'     group_by(x = !! db_bin(mpg)) %>%
#'     tally()
#' 
#'   # Uses binwidth which overrides bins
#'   mtcars %>% 
#'     group_by(x = !! db_bin(mpg, binwidth = 10)) %>%
#'     tally()
#' 
#' @export
#' @importFrom rlang enexpr expr
db_bin <- function(var, bins = 30, binwidth = NULL) {
  var <- enexpr(var)
  
  range <- expr(max(!!var) - min(!!var))
  
  if(is.null(binwidth)){
    binwidth <- expr((!!range) / (!!bins))
  } else {
    bins <- expr(as.integer((!!range) / (!!binwidth)))
  }
  
  # Made more sense to use floor() to determine the bin value than
  # using the bin number or the max or mean, feel free to customize
  bin_number <- expr(as.integer(floor(((!!var) - min(!!var)) / (!!binwidth))))
  
  # Value(s) that match max(x) will be rebased to bin -1, giving us the exact number of bins requested
  expr(((!!binwidth) *
          ifelse((!!bin_number) == (!!bins), (!!bin_number) - 1, (!!bin_number))) + min(!!var))
  
}


