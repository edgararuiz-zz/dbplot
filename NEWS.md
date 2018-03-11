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