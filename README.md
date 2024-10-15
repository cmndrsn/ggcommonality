
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ggcommonality

<!-- badges: start -->
<!-- badges: end -->

The goal of ggcommonality is to produce bar plots of unique and joint
effects from commonality analyses. The function outputs a bar plots with
unique and common effects for each commonality partition. The function
is scalable and takes formula notation for input. This package is very
fresh, so its functionality is quite limited.

Partitions are plotted sequentially in alphabetical order, starting with
unique effects and are built iteratively with joint effects at higher
orders on top. This means there are redundancies between partitions, and
the plot can be deceptive if you don’t take the total explained variance
into account.

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

To get the x and y coordinates passed to `ggplot2::geom_rect()` when
making the plot, you can use the following line of code, which returns a
list with (1) the data frame used to create the barplot for positive
commonalities (from xmin, xmax, ymin, and ymax coordinates); (2) the
data frame used to create the black outline for the positive effects;
(3) the data frame used to create the barplot for negative
commonalities; and (4) the data frame used to create the black outline
for the negative effects.

``` r
get_commonality_barplot_df(yhat_model) 
#> [[1]]
#>                   names   vals total category plot_order n_cues cue value
#> 5                   cyl 0.0235  3.07      cyl          1      1   1   cyl
#> 1              cyl,  vs 0.0106  1.39      cyl          2      2   1   cyl
#> 2              cyl,  vs 0.0106  1.39      cyl          2      2   2    vs
#> 3            cyl,  drat 0.0110  1.43      cyl          3      2   1   cyl
#> 4            cyl,  drat 0.0110  1.43      cyl          3      2   2  drat
#> 6            cyl,  disp 0.0884 11.55      cyl          4      2   1   cyl
#> 7            cyl,  disp 0.0884 11.55      cyl          4      2   2  disp
#> 8        cyl, disp,  vs 0.1538 20.09      cyl          5      3   1   cyl
#> 9        cyl, disp,  vs 0.1538 20.09      cyl          5      3   2  disp
#> 10       cyl, disp,  vs 0.1538 20.09      cyl          5      3   3    vs
#> 11     cyl, disp,  drat 0.1645 21.50      cyl          6      3   1   cyl
#> 12     cyl, disp,  drat 0.1645 21.50      cyl          6      3   2  disp
#> 13     cyl, disp,  drat 0.1645 21.50      cyl          6      3   3  drat
#> 14 cyl, disp, vs,  drat 0.2783 36.37      cyl          7      4   1   cyl
#> 15 cyl, disp, vs,  drat 0.2783 36.37      cyl          7      4   2  disp
#> 16 cyl, disp, vs,  drat 0.2783 36.37      cyl          7      4   3    vs
#> 17 cyl, disp, vs,  drat 0.2783 36.37      cyl          7      4   4  drat
#> 23                 disp 0.0248  3.24     disp          1      1   1  disp
#> 24           cyl,  disp 0.0884 11.55     disp          2      2   1   cyl
#> 25           cyl,  disp 0.0884 11.55     disp          2      2   2  disp
#> 21          disp,  drat 0.0074  0.97     disp          3      2   1  disp
#> 22          disp,  drat 0.0074  0.97     disp          3      2   2  drat
#> 26       cyl, disp,  vs 0.1538 20.09     disp          4      3   1   cyl
#> 27       cyl, disp,  vs 0.1538 20.09     disp          4      3   2  disp
#> 28       cyl, disp,  vs 0.1538 20.09     disp          4      3   3    vs
#> 18      disp, vs,  drat 0.0011  0.15     disp          5      3   1  disp
#> 19      disp, vs,  drat 0.0011  0.15     disp          5      3   2    vs
#> 20      disp, vs,  drat 0.0011  0.15     disp          5      3   3  drat
#> 29     cyl, disp,  drat 0.1645 21.50     disp          6      3   1   cyl
#> 30     cyl, disp,  drat 0.1645 21.50     disp          6      3   2  disp
#> 31     cyl, disp,  drat 0.1645 21.50     disp          6      3   3  drat
#> 32 cyl, disp, vs,  drat 0.2783 36.37     disp          7      4   1   cyl
#> 33 cyl, disp, vs,  drat 0.2783 36.37     disp          7      4   2  disp
#> 34 cyl, disp, vs,  drat 0.2783 36.37     disp          7      4   3    vs
#> 35 cyl, disp, vs,  drat 0.2783 36.37     disp          7      4   4  drat
#> 56                 drat 0.0047  0.61     drat          1      1   1  drat
#> 51            vs,  drat 0.0009  0.11     drat          2      2   1    vs
#> 52            vs,  drat 0.0009  0.11     drat          2      2   2  drat
#> 59           cyl,  drat 0.0110  1.43     drat          3      2   1   cyl
#> 60           cyl,  drat 0.0110  1.43     drat          3      2   2  drat
#> 57          disp,  drat 0.0074  0.97     drat          4      2   1  disp
#> 58          disp,  drat 0.0074  0.97     drat          4      2   2  drat
#> 53      disp, vs,  drat 0.0011  0.15     drat          5      3   1  disp
#> 54      disp, vs,  drat 0.0011  0.15     drat          5      3   2    vs
#> 55      disp, vs,  drat 0.0011  0.15     drat          5      3   3  drat
#> 61     cyl, disp,  drat 0.1645 21.50     drat          6      3   1   cyl
#> 62     cyl, disp,  drat 0.1645 21.50     drat          6      3   2  disp
#> 63     cyl, disp,  drat 0.1645 21.50     drat          6      3   3  drat
#> 64 cyl, disp, vs,  drat 0.2783 36.37     drat          7      4   1   cyl
#> 65 cyl, disp, vs,  drat 0.2783 36.37     drat          7      4   2  disp
#> 66 cyl, disp, vs,  drat 0.2783 36.37     drat          7      4   3    vs
#> 67 cyl, disp, vs,  drat 0.2783 36.37     drat          7      4   4  drat
#> 36                   vs 0.0001  0.01       vs          1      1   1    vs
#> 42             cyl,  vs 0.0106  1.39       vs          2      2   1   cyl
#> 43             cyl,  vs 0.0106  1.39       vs          2      2   2    vs
#> 37            vs,  drat 0.0009  0.11       vs          3      2   1    vs
#> 38            vs,  drat 0.0009  0.11       vs          3      2   2  drat
#> 44       cyl, disp,  vs 0.1538 20.09       vs          4      3   1   cyl
#> 45       cyl, disp,  vs 0.1538 20.09       vs          4      3   2  disp
#> 46       cyl, disp,  vs 0.1538 20.09       vs          4      3   3    vs
#> 39      disp, vs,  drat 0.0011  0.15       vs          5      3   1  disp
#> 40      disp, vs,  drat 0.0011  0.15       vs          5      3   2    vs
#> 41      disp, vs,  drat 0.0011  0.15       vs          5      3   3  drat
#> 47 cyl, disp, vs,  drat 0.2783 36.37       vs          6      4   1   cyl
#> 48 cyl, disp, vs,  drat 0.2783 36.37       vs          6      4   2  disp
#> 49 cyl, disp, vs,  drat 0.2783 36.37       vs          6      4   3    vs
#> 50 cyl, disp, vs,  drat 0.2783 36.37       vs          6      4   4  drat
#>       x_min    x_max category_numeric  y_min  y_max
#> 5  2.500000 3.500000                1 0.0000 0.0235
#> 1  2.500000 3.000000                1 0.0235 0.0341
#> 2  3.000000 3.500000                1 0.0235 0.0341
#> 3  2.500000 3.000000                1 0.0341 0.0451
#> 4  3.000000 3.500000                1 0.0341 0.0451
#> 6  2.500000 3.000000                1 0.0451 0.1335
#> 7  3.000000 3.500000                1 0.0451 0.1335
#> 8  2.500000 2.833333                1 0.1335 0.2873
#> 9  2.833333 3.166667                1 0.1335 0.2873
#> 10 3.166667 3.500000                1 0.1335 0.2873
#> 11 2.500000 2.833333                1 0.2873 0.4518
#> 12 2.833333 3.166667                1 0.2873 0.4518
#> 13 3.166667 3.500000                1 0.2873 0.4518
#> 14 2.500000 2.750000                1 0.4518 0.7301
#> 15 2.750000 3.000000                1 0.4518 0.7301
#> 16 3.000000 3.250000                1 0.4518 0.7301
#> 17 3.250000 3.500000                1 0.4518 0.7301
#> 23 4.000000 5.000000                2 0.0000 0.0248
#> 24 4.000000 4.500000                2 0.0248 0.1132
#> 25 4.500000 5.000000                2 0.0248 0.1132
#> 21 4.000000 4.500000                2 0.1132 0.1206
#> 22 4.500000 5.000000                2 0.1132 0.1206
#> 26 4.000000 4.333333                2 0.1206 0.2744
#> 27 4.333333 4.666667                2 0.1206 0.2744
#> 28 4.666667 5.000000                2 0.1206 0.2744
#> 18 4.000000 4.333333                2 0.2744 0.2755
#> 19 4.333333 4.666667                2 0.2744 0.2755
#> 20 4.666667 5.000000                2 0.2744 0.2755
#> 29 4.000000 4.333333                2 0.2755 0.4400
#> 30 4.333333 4.666667                2 0.2755 0.4400
#> 31 4.666667 5.000000                2 0.2755 0.4400
#> 32 4.000000 4.250000                2 0.4400 0.7183
#> 33 4.250000 4.500000                2 0.4400 0.7183
#> 34 4.500000 4.750000                2 0.4400 0.7183
#> 35 4.750000 5.000000                2 0.4400 0.7183
#> 56 5.500000 6.500000                3 0.0000 0.0047
#> 51 5.500000 6.000000                3 0.0047 0.0056
#> 52 6.000000 6.500000                3 0.0047 0.0056
#> 59 5.500000 6.000000                3 0.0056 0.0166
#> 60 6.000000 6.500000                3 0.0056 0.0166
#> 57 5.500000 6.000000                3 0.0166 0.0240
#> 58 6.000000 6.500000                3 0.0166 0.0240
#> 53 5.500000 5.833333                3 0.0240 0.0251
#> 54 5.833333 6.166667                3 0.0240 0.0251
#> 55 6.166667 6.500000                3 0.0240 0.0251
#> 61 5.500000 5.833333                3 0.0251 0.1896
#> 62 5.833333 6.166667                3 0.0251 0.1896
#> 63 6.166667 6.500000                3 0.0251 0.1896
#> 64 5.500000 5.750000                3 0.1896 0.4679
#> 65 5.750000 6.000000                3 0.1896 0.4679
#> 66 6.000000 6.250000                3 0.1896 0.4679
#> 67 6.250000 6.500000                3 0.1896 0.4679
#> 36 7.000000 8.000000                4 0.0000 0.0001
#> 42 7.000000 7.500000                4 0.0001 0.0107
#> 43 7.500000 8.000000                4 0.0001 0.0107
#> 37 7.000000 7.500000                4 0.0107 0.0116
#> 38 7.500000 8.000000                4 0.0107 0.0116
#> 44 7.000000 7.333333                4 0.0116 0.1654
#> 45 7.333333 7.666667                4 0.0116 0.1654
#> 46 7.666667 8.000000                4 0.0116 0.1654
#> 39 7.000000 7.333333                4 0.1654 0.1665
#> 40 7.333333 7.666667                4 0.1654 0.1665
#> 41 7.666667 8.000000                4 0.1654 0.1665
#> 47 7.000000 7.250000                4 0.1665 0.4448
#> 48 7.250000 7.500000                4 0.1665 0.4448
#> 49 7.500000 7.750000                4 0.1665 0.4448
#> 50 7.750000 8.000000                4 0.1665 0.4448
#> 
#> [[2]]
#> # A tibble: 4 × 5
#>   category y_min y_max x_min x_max
#>   <chr>    <dbl> <dbl> <dbl> <dbl>
#> 1 cyl          0 0.730   2.5   3.5
#> 2 disp         0 0.718   4     5  
#> 3 drat         0 0.468   5.5   6.5
#> 4 vs           0 0.445   7     8  
#> 
#> [[3]]
#>             names    vals total category plot_order 4 n_cues cue value    x_min
#> 4             cyl  0.0000   0.0      cyl          1        1   1   cyl 2.500000
#> 1  cyl, vs,  drat -0.0038  -0.5      cyl          2        3   1   cyl 2.500000
#> 2  cyl, vs,  drat -0.0038  -0.5      cyl          2        3   2    vs 2.833333
#> 3  cyl, vs,  drat -0.0038  -0.5      cyl          2        3   3  drat 3.166667
#> 7            disp  0.0000   0.0     disp          1        1   1  disp 4.000000
#> 5       disp,  vs  0.0000   0.0     disp          2        2   1  disp 4.000000
#> 6       disp,  vs  0.0000   0.0     disp          2        2   2    vs 4.500000
#> 17           drat  0.0000   0.0     drat          1        1   1  drat 5.500000
#> 14 cyl, vs,  drat -0.0038  -0.5     drat          2        3   1   cyl 5.500000
#> 15 cyl, vs,  drat -0.0038  -0.5     drat          2        3   2    vs 5.833333
#> 16 cyl, vs,  drat -0.0038  -0.5     drat          2        3   3  drat 6.166667
#> 13             vs  0.0000   0.0       vs          1        1   1    vs 7.000000
#> 11      disp,  vs  0.0000   0.0       vs          2        2   1  disp 7.000000
#> 12      disp,  vs  0.0000   0.0       vs          2        2   2    vs 7.500000
#> 8  cyl, vs,  drat -0.0038  -0.5       vs          3        3   1   cyl 7.000000
#> 9  cyl, vs,  drat -0.0038  -0.5       vs          3        3   2    vs 7.333333
#> 10 cyl, vs,  drat -0.0038  -0.5       vs          3        3   3  drat 7.666667
#>       x_max category_numeric y_min   y_max
#> 4  3.500000                1     0  0.0000
#> 1  2.833333                1     0 -0.0038
#> 2  3.166667                1     0 -0.0038
#> 3  3.500000                1     0 -0.0038
#> 7  5.000000                2     0  0.0000
#> 5  4.500000                2     0  0.0000
#> 6  5.000000                2     0  0.0000
#> 17 6.500000                3     0  0.0000
#> 14 5.833333                3     0 -0.0038
#> 15 6.166667                3     0 -0.0038
#> 16 6.500000                3     0 -0.0038
#> 13 8.000000                4     0  0.0000
#> 11 7.500000                4     0  0.0000
#> 12 8.000000                4     0  0.0000
#> 8  7.333333                4     0 -0.0038
#> 9  7.666667                4     0 -0.0038
#> 10 8.000000                4     0 -0.0038
#> 
#> [[4]]
#> # A tibble: 4 × 5
#>   category   y_min   y_max x_min x_max
#>   <chr>      <dbl>   <dbl> <dbl> <dbl>
#> 1 cyl      -0.0038 -0.0038   2.5   3.5
#> 2 disp      0       0        4     5  
#> 3 drat     -0.0038 -0.0038   5.5   6.5
#> 4 vs       -0.0038 -0.0038   7     8
```

A future version of the package will include the possibility to add the
total explained variance as an additional bar. I would also like to
incorporate bootstrapped confidence intervals.
