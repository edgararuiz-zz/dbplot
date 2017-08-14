dbplot
================

[![Build Status](https://travis-ci.org/edgararuiz/dbplot.svg?branch=master)](https://travis-ci.org/edgararuiz/dbplot)

Leverages `dplyr` to process the calculations of a plot inside a database. This package provides helper functions that abstract the work at three levels:

-   Outputs a `ggplot2` (*highest*)
-   Outputs the calculations (*medium*)
-   Outputs the formula needed to calculate bins (*lowest*)

Not available in CRAN yet, so it needs to be installed via GitHub:

``` r
devtools::install_github("edgararuiz/dbplot")
```
