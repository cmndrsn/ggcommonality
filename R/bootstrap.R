#' Perform bootstrapping on commonality coefficients
#'
#' Get commonality coefficients for n replications
#'
#' @param formula Formula to be used in helper_commonality_bootstrap
#' @param data Data to be used in helper_commonality_bootstrap
#' @param groups Groups to be used in helper_commonality_bootstrap
#' @param n_replications Number of replications in bootstrap
#' @return Data frame containing commonality partitions for replications.
#' @examples
#' # 1000 - 10000 replications recommended for publications.
#' run_commonality_bootstrap(formula = cyl ~ mpg + hp,
#' data = mtcars,
#' groups = "gear",
#' n_replications = 100) |> suppressWarnings()
#' @export
run_commonality_bootstrap <- function(formula,
                                      data,
                                      groups,
                                      n_replications = 10000) {

  data_simplified <- .helper_simplify_df(
    formula = formula,
    data = data,
    groups = groups)
  data_boot <- pbapply::pbreplicate(n_replications, .helper_resample_commonality(
    formula,
    data_simplified,
    groups
  )
  )

  return(data_boot)
}

#' Drop columns unnecessary to bootstrap commonality analysis
#'
#' @param formula Formula to be used in helper_commonality_bootstrap
#' @param data Data to be used in helper_commonality_bootstrap
#' @param groups Groups to be used in helper_commonality_bootstrap
#' @return Data.frame. Drops columns that don't include terms in formula
#' @examples
#' .helper_simplify_df(formula = cyl ~ mpg + hp, data = mtcars, groups = "gear")
#' @export
.helper_simplify_df <- function(formula,
                        data,
                        groups) {
  regressand_name <- terms(formula)[[2]]
  regressor_names <- labels(terms(formula))
  var_names <- as.character(c(regressand_name, regressor_names, groups))
  data <- data[,var_names]
  return(data)
}

#'
#' Commonality Coefficients From Resampled Data
#'
#' Calculate commonality coefficients in bootstrap procedure
#'
#' @param formula Formula to be used in helper_commonality_bootstrap
#' @param data Data to be used in helper_commonality_bootstrap
#' @param groups Groups to be used in helper_commonality_bootstrap
#'
#' @return Vector of commonality coefficients on resampled data.
#' @import yhat
#' @export
.helper_resample_commonality <- function(formula,
                                 data,
                                 groups) {

  resample_df <- mosaic::resample(x = data, groups = groups, replace = TRUE)
  result <- yhat::regr(lm(formula = formula,
                data = resample_df))$Commonality_Data$CC[,1]
  return(result)
}
#' @examples
#' .helper_resample_commonality(formula = cyl ~ mpg + hp,
#' data = mtcars, groups = "gear") |> suppressWarnings()
#'




