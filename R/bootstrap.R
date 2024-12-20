#' Perform bootstrapping on commonality coefficients
#'
#' Get commonality coefficients for n replications
#'
#' @param formula Formula to be used in helper_commonality_bootstrap
#' @param data Data to be used in helper_commonality_bootstrap
#' @param groups Groups to be used in helper_commonality_bootstrap
#' @param n_replications Number of replications in bootstrap
#' @param resample_type Method for boostrap resampling. Either "random" or "fixed"
#' @return Data frame containing commonality partitions for replications.
#' @export
#' @examples
#' run_commonality_bootstrap(formula = cyl ~ mpg + hp,
#' data = mtcars,
#' groups = "gear",
#' n_replications = 100) |> suppressWarnings()
run_commonality_bootstrap <- function(formula,
                                      data,
                                      groups,
                                      resample_type = "random",
                                      n_replications = 10000) {

  data_simplified <- .helper_simplify_df(
    formula = formula,
    data = data,
    groups = groups)
  data_boot <- pbapply::pbreplicate(n_replications, .helper_resample_commonality(
    formula,
    data_simplified,
    groups,
    resample_type
    )
  )

  return(data_boot)
}

#' Drop columns unnecessary to bootstrap commonality analysis
#'
#' Gets rid of columns not specified in formula
#'
#' @param formula Formula to be used in helper_commonality_bootstrap
#' @param data Data to be used in helper_commonality_bootstrap
#' @param groups Groups to be used in helper_commonality_bootstrap
#' @return Data.frame. Drops columns that don't include terms in formula
.helper_simplify_df <- function(formula,
                        data,
                        groups) {
  regressand_name <- terms(formula)[[2]]
  regressor_names <- labels(terms(formula))
  var_names <- as.character(c(regressand_name, regressor_names, groups))
  data <- data[,var_names]
  return(data)
}

#' Commonality Coefficients From Resampled Data
#'
#' Calculate commonality coefficients in bootstrap procedure
#'
#' @param formula Formula to be used in helper_commonality_bootstrap
#' @param data Data to be used in helper_commonality_bootstrap
#' @param groups Groups to be used in helper_commonality_bootstrap
#' @param resample_type Character vector specifying whether resampling should be fixed or random. See details.
#' @return Vector of commonality coefficients on resampled data.
.helper_resample_commonality <- function(formula,
                                 data,
                                 groups,
                                 resample_type) {

  if(resample_type == "random") {
    resample_df <- mosaic::resample(x = data,
                                    groups = groups,
                                    replace = TRUE)
    result <- yhat::regr(lm(formula = formula,
                            data = resample_df))$Commonality_Data$CC[,1]
  }
  else if(resample_type == "fixed") {

    # get regressand name
    regressand_name <- terms(formula)[[2]]
    # get regressor names
    regressor_names <- labels(terms(formula))

    # fit model using user-specified function
    mod <- lm(formula,
              data)
    # get fitted values
    fit <- fitted(mod)
    # get residuals
    e <- residuals(mod)
    # get columns corresponding to regressors
    X <- data[, regressor_names]
    # resample residuals
    # first add fitted values and residuals to original dataframe
    data_w_fit <- data.frame(data,
                             e,
                             fit)
    # now resample dataframe by group variable
    e_hat_df <- mosaic::resample(data_w_fit,
                                 groups = groups,
                                 replace = TRUE)
    # get residuals
    e_hat <- e_hat_df$e
    # add residual error to fitted values
    y <- fit + e_hat
    # now that errors are resampled, we can store this in a data.frame
    resample_df <- as.data.frame(cbind(y, X))
    # rename variables from matrix to those in original data frame

    # assign names to resample_df
    names(resample_df) <- c(regressand_name, regressor_names)
    # get result
    result <- yhat::regr(
      lm(
        formula = formula,
        data = resample_df
      )
    )$Commonality_Data$CC[,1]
  } else {
    stop("type argument must be either 'fixed' or 'random'. See Fox (2008) for details.")
  }
  return(result)
}





