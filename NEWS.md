# dbplot 0.1.1.9000

## Bug Fixes

- Coerce aggregate results using `as.numeric()` to handle `integer64` results (#6)

- `compute` functions now return an ungrouped `data.frame`

# dbplot 0.1.1

## Bug Fixes

- Fixed `unused argument (na.rm = TRUE)` message when used with the CRAN version of `dbplyr` (#3)