
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ggcommonality

<!-- badges: start -->
<!-- badges: end -->

The goal of ggcommonality is to produce bar plots of unique and joint
effects from commonality analyses. The function outputs a bar plots with
unique and common effects for each commonality partition. The function
is scalable and takes formula notation for input. This package is very
fresh, so its functionality is quite limited.

## Installation

You can install the development version of ggcommonality from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("cmndrsn/ggcommonality")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(ggcommonality)
# import data
data(mtcars)
# fit model with yhat
yhat_model <- yhat::regr(
  lm(
    formula = mpg ~ cyl + disp + vs + drat,
    data = mtcars
    )
  )
ggcommonality(yhat_model) +
  ggplot2::theme_bw()
```

<img src="man/figures/README-example-1.png" width="100%" /> We can
compare the bar plot output to the unique and common effects from the
model:

``` r
knitr::kable(yhat_model$Commonality_Data$CC)
```

|                                   | Coefficient | % Total |
|:----------------------------------|------------:|--------:|
| Unique to cyl                     |      0.0235 |    3.07 |
| Unique to disp                    |      0.0248 |    3.24 |
| Unique to vs                      |      0.0001 |    0.01 |
| Unique to drat                    |      0.0047 |    0.61 |
| Common to cyl, and disp           |      0.0884 |   11.55 |
| Common to cyl, and vs             |      0.0106 |    1.39 |
| Common to disp, and vs            |      0.0000 |    0.00 |
| Common to cyl, and drat           |      0.0110 |    1.43 |
| Common to disp, and drat          |      0.0074 |    0.97 |
| Common to vs, and drat            |      0.0009 |    0.11 |
| Common to cyl, disp, and vs       |      0.1538 |   20.09 |
| Common to cyl, disp, and drat     |      0.1645 |   21.50 |
| Common to cyl, vs, and drat       |     -0.0038 |   -0.50 |
| Common to disp, vs, and drat      |      0.0011 |    0.15 |
| Common to cyl, disp, vs, and drat |      0.2783 |   36.37 |
| Total                             |      0.7652 |  100.00 |
