#' Perform bootstrapping on commonality coefficients
#'
#' Get commonality coefficients for n replications
#'
#' @param formula Formula to be used in helper_commonality_bootstrap
#' @param data Data to be used in helper_commonality_bootstrap
#' @param groups Column to resample within in bootstrap (see mosaic::resample()).
#' @param n_replications Number of replications in bootstrap
#' @param resample_type Method for boostrap resampling. Either "random", "fixed", or "wild".
#' @param wild_type If resample_type == "wild", either "Gaussian" to
#' multiply resampled residuals by random constants from the normal distribution,
#' or sign to randomly multiply half of the residuals by +1 and half by -1.
#' @param seed Numeric. Value to set R's random number generator to for reproducibility
#' This provides a solution to "fixed" in the presence of model heteroscedasticity
#' @return Data frame containing commonality partitions for replications.
#' @export
#' @examples
#' run_commonality_bootstrap(formula = cyl ~ mpg + hp,
#' data = mtcars,
#' groups = "gear",
#' n_replications = 100) |> suppressWarnings()
run_commonality_bootstrap <- function(
    formula,
    data,
    groups = NULL,
    resample_type = "random",
    wild_type = "gaussian",
    n_replications = 100,
    seed = NULL
    ) {
  if(!is.null(seed)) set.seed(seed)
  data_simplified <- .helper_simplify_df(
    formula = formula,
    data = data,
    groups = groups
    )
  data_boot <- pbapply::pbreplicate(
    n_replications,
    .helper_resample_commonality(
    formula,
    data_simplified,
    groups,
    resample_type,
    wild_type
    )
  )

  return(data_boot)
}

#' Drop columns unnecessary to bootstrap commonality analysis
#'
#' Gets rid of columns not specified in formula
#' @noRd
#' @param formula Formula to be used in helper_commonality_bootstrap
#' @param data Data to be used in helper_commonality_bootstrap
#' @param groups Column to resample within in bootstrap (see mosaic::resample()).
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
#' Performs bootstrapping for coefficients. If resample_type is "fixed" or "wild",
#' model errors are randomly resampled in bootstrap rather than data observations.
#' For the wild bootstrap, these errors are then randomly multiplied by positive or negative 1 ("sign"),
#' or by values sampled from the standard normal distribution to relax assumptions of errors being
#' symmetrically distributed about 0.
#' @noRd
#' @param formula Formula to be used in helper_commonality_bootstrap
#' @param data Data to be used in helper_commonality_bootstrap
#' @param groups Column to resample within in bootstrap (see mosaic::resample()).
#' @param resample_type Character vector specifying whether resampling should be fixed, random, or wild. See details.
#' @param wild_type One of "gaussian" or "sign"
#' @return Vector of commonality coefficients on resampled data.
.helper_resample_commonality <- function(
    formula,
     data,
     groups,
     resample_type,
     wild_type = "gaussian"
    ) {

  if(resample_type == "random") {
    resample_df <- mosaic::resample(x = data,
                                    groups = groups,
                                    replace = TRUE)
    result <- yhat::regr(lm(formula = formula,
                            data = resample_df))$Commonality_Data$CC[,1]
  }
  else if(resample_type == "fixed"|resample_type == "wild") {

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
    # for wild bootstrap, we can randomly swap signs to deal with heteroscedasticity
    if(resample_type == "wild") {
      # based on https://stats.stackexchange.com/questions/408651
      if(wild_type == "sign") {
        e_hat <- e_hat * mosaic::resample(
          c(1,-1),
          size =  length(e_hat)
          )
      } else if (wild_type == "gaussian") {
        e_hat <- e_hat * stats::rnorm(
          n = length(e_hat)
          )
      } else {
        stop("If resample_type == 'wild', wild_type must be one of 'gaussian' or 'sign'")
      }
    }
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
    stop("type argument must be either 'fixed', 'random', or 'wild'.")
  }
  return(result)
}





