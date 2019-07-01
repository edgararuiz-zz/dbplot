# dbplot 0.3.2

- Addresses issue of `'symbol' is not subsettable` (#24)

# dbplot 0.3.1

- New `db_compute_raster2()` function includes upper limit

- Removes dependencies on pipes

- Improves compliance with rlangs `quo()` vs `expr()` usage rules

- Separates Spark and default behaivor of `db_compute_boxplot()` and adds tests

# dbplot 0.3.0

- Supports multiple aggregations for bar and line charts

- Supports naming aggregations for bar and line charts

# dbplot 0.2.1

- Adds compatability with rlang 0.2.0 upgrade

- Improves dependency management

# dbplot 0.2.0

## Bug Fixes

- Adds compatability with dbplyr 1.2.0 upgrade

- Adds `complete` argument to `db_compute_raster()` and `dbplot_raster()` which fills in empty bins (#5)

- Coerce aggregate results using `as.numeric()` to handle `integer64` results (#6)

- `compute` functions now return an ungrouped `data.frame`

# dbplot 0.1.1

## Bug Fixes

- Fixed `unused argument (na.rm = TRUE)` message when used with the CRAN version of `dbplyr` (#3)
