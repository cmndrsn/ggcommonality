
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ggcommonality <img src="man/ggcommonality_sticker.png" align="right"/>

<!-- badges: start -->

<!-- badges: end -->

ggcommonality creates bar plots of unique and joint effects from a
commonality analysis of a linear regression model. The function outputs
a bar plots with unique and common effects for each commonality
partition.

The function is scalable to multiple variables and takes formula
notation for input, calling on the `yhat` package (Nimon, Oswald, and
Roberts. 2023).

This function builds bar plots in the style of those appearing in the
[MAPLE Lab’s](https://maplelab.net) work applying commonality analysis
to the compositions of Bach and Chopin (Anderson and Schutz 2022).

Partitions are plotted sequentially in alphabetical order, starting with
unique effects and are built iteratively with joint effects at higher
orders on top.

## Installation

You can install the development version of ggcommonality from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("cmndrsn/ggcommonality")
```

## Example

The function produces a barplot of a commonality analysis from a formula
and data set.

``` r
library(ggcommonality)
library(ggplot2)
# import data
data(mtcars)

p <- ggcommonality(formula = mpg ~ cyl + disp + vs,
                   data = mtcars)
  

print(p)
```

<img src="man/figures/README-example-1.png" width="100%" />

The plot is customizable and can be used with ggprotos.

``` r
p + scale_fill_manual(
  values = c(
    "#7fc97f",
    "#beaed4",
    "#fdc086"
    )
) 
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

We can compare the bar plot output to the unique and common effects from
the model:

``` r
yhat_model <- yhat::regr(
  lm(
    formula = mpg ~ cyl + disp + vs,
    data = mtcars
  )
)
knitr::kable(
  yhat_model$Commonality_Data$CC
)
```

|                             | Coefficient | % Total |
|:----------------------------|------------:|--------:|
| Unique to cyl               |      0.0344 |    4.53 |
| Unique to disp              |      0.0322 |    4.24 |
| Unique to vs                |      0.0010 |    0.13 |
| Common to cyl, and disp     |      0.2529 |   33.25 |
| Common to cyl, and vs       |      0.0068 |    0.89 |
| Common to disp, and vs      |      0.0012 |    0.15 |
| Common to cyl, disp, and vs |      0.4320 |   56.81 |
| Total                       |      0.7605 |  100.00 |

To get the x and y coordinates passed to `geom_rect()` when making the
plot, you can use the `df_ggcommonality()` function, which returns a
list with (1) the data frame used to create the barplot for positive
commonalities (from xmin, xmax, ymin, and ymax coordinates); (2) the
data frame used to create the black outline for the positive effects;
(3) the data frame used to create the barplot for negative
commonalities; and (4) the data frame used to create the black outline
for the negative effects.

``` r
df_commonality <- df_ggcommonality(
  formula = mpg ~ cyl + disp + vs,
  data = mtcars
)

## Make output shorter
lapply(
  df_commonality,
  head
)
#> [[1]]
#>            names   vals total category plot_order n_cues   type cue value x_min
#> 3            cyl 0.0344  4.53      cyl          1      1 unique   1   cyl   2.5
#> 1       cyl,  vs 0.0068  0.89      cyl          2      2 common   1   cyl   2.5
#> 2       cyl,  vs 0.0068  0.89      cyl          2      2 common   2    vs   3.0
#> 4     cyl,  disp 0.2529 33.25      cyl          3      2 common   1   cyl   2.5
#> 5     cyl,  disp 0.2529 33.25      cyl          3      2 common   2  disp   3.0
#> 6 cyl, disp,  vs 0.4320 56.81      cyl          4      3 common   1   cyl   2.5
#>      x_max category_numeric  y_min  y_max
#> 3 3.500000                1 0.0000 0.0344
#> 1 3.000000                1 0.0344 0.0412
#> 2 3.500000                1 0.0344 0.0412
#> 4 3.000000                1 0.0412 0.2941
#> 5 3.500000                1 0.0412 0.2941
#> 6 2.833333                1 0.2941 0.7261
#> 
#> [[2]]
#> # A tibble: 3 × 6
#>   category y_min y_max x_min x_max x_mid
#>   <chr>    <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1 cyl          0 0.726   2.5   3.5   3  
#> 2 disp         0 0.718   4     5     4.5
#> 3 vs           0 0.441   5.5   6.5   6  
#> 
#> [[3]]
#>   names vals total category plot_order 2 3 n_cues   type cue value x_min x_max
#> 1   cyl    0     0      cyl          1          1 unique   1   cyl   2.5   2.5
#> 4   cyl    0     0      cyl          1          1 unique   1   cyl   3.5   3.5
#> 2  disp    0     0     disp          1          1 unique   1  disp   5.0   5.0
#> 5  disp    0     0     disp          1          1 unique   1  disp   4.0   4.0
#> 3    vs    0     0       vs          1          1 unique   1    vs   5.5   5.5
#> 6    vs    0     0       vs          1          1 unique   1    vs   6.5   6.5
#>   category_numeric y_min y_max
#> 1                1     0     0
#> 4                1     0     0
#> 2                2     0     0
#> 5                2     0     0
#> 3                3     0     0
#> 6                3     0     0
#> 
#> [[4]]
#> # A tibble: 3 × 6
#>   category y_min y_max x_min x_max x_mid
#>   <chr>    <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1 cyl          0     0   2.5   3.5   3  
#> 2 disp         0     0   4     5     4.5
#> 3 vs           0     0   5.5   6.5   6
```

# Adding confidence intervals

You can add percentile-based bootstrap confidence intervals using the
`ci_ggcommonality` function. The `resample_type` argument specifies
whether to generate random-*x*, confidence intervals, fixed-*x*, or
wild-*x* confidence intervals. The
[appendices](https://www.john-fox.ca/Companion/) to Fox and Weisberg
(2018) summarizes the advantages and disadvantages of fixed
vs. random-*x* bootstrapping. Wild-*x* provides a solution to fixed-*x*
for models featuring heteroscedasticity by multiplying resampled
residuals with constants sampled from a Gaussian distribution
(`wild_type = "gaussian"`), or by randomly multiplying half by 1 and
half by -1 (`wild_type = "sign"`).

If `stack_by = "partition"`, confidence intervals represent the sum of
unique and joint effects for individual commonality partitions.
Otherwise, if `stack_by = "common"`, separate confidence intervals are
generated for the sum of unique effects and the sum of joint effects.

## Comparing random-*x* bootstrap confidence intervals

``` r
# set r's random number generator
set.seed(1)
library(patchwork)

lm_cars <- mpg ~ cyl + disp + vs

p <- p + theme_void() + ylim(0, 1.2) + theme(legend.position = 'none')

ci_random <- p +
  ci_ggcommonality(
    formula = lm_cars,
     data = mtcars,
     n_replications = 100,
    resample_type = "random"
) +
  labs(subtitle = "Random-x")


ci_fixed <- p +
  ci_ggcommonality(
    formula = lm_cars,
     data = mtcars,
     n_replications = 100,
    resample_type = "fixed"
)+
  labs(subtitle = "Fixed-x") 

ci_gaussian <- p +
  ci_ggcommonality(
    formula = lm_cars,
     data = mtcars,
     n_replications = 100,
    resample_type = "wild"
)+
  labs(subtitle = "Wild (Gaussian)") 

ci_sign <- p +
  ci_ggcommonality(
    formula = lm_cars,
     data = mtcars,
     n_replications = 100,
    resample_type = "wild",
    wild_type = "sign"
)+
  labs(subtitle = "Wild (sign)") 

(ci_random|ci_fixed|ci_gaussian|ci_sign)
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

# Stack by unique vs. common effects

``` r
p2 <- ggcommonality(
  lm_cars,
  data = mtcars,
  stack_by = "common"
)

p2 +
  ci_ggcommonality(
    formula = lm_cars,
    data = mtcars,
    n_replications = 100,
    stack_by = "common",
    resample_type = "wild",
    ci_sign = "",
    width = 0.5,
    alpha = 0.5
) 
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

# References

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-anderson2022exploring" class="csl-entry">

Anderson, Cameron J, and Michael Schutz. 2022. “Exploring Historic
Changes in Musical Communication: Deconstructing Emotional Cues in
Preludes by Bach and Chopin.” *Psychology of Music* 50 (5): 1424–42.

</div>

<div id="ref-fox2018r" class="csl-entry">

Fox, John, and Sanford Weisberg. 2018. *An r Companion to Applied
Regression*. Sage publications.

</div>

<div id="ref-nimon2023r" class="csl-entry">

Nimon, Kim, Fred Oswald, and J. Kyle Roberts. 2023. *Yhat: Interpreting
Regression Effects*. <https://CRAN.R-project.org/package=yhat>.

</div>

</div>
