#' Generate percentile-based confidence intervals for commonality coefficients
#'
#' Create random- or fixed-effect percentile-based bootstrap intervals.
#'
#' @noRd
#' @author Cameron Anderson, Julianne Heitelman
#' @param formula Formula corresponding to linear regression model
#' @param data  Data to sample observations from
#' @param sample_column Optional column to sample from
#' @param resample_type Method for boostrap resampling. Either "random", "fixed", or "wild".
#' @param wild_type If resample_type == "wild", either "Gaussian" to
#' multiply resampled residuals by random constants from the normal distribution,
#' or sign to randomly multiply half of the residuals by +1 and half by -1.
#' This provides a solution to "fixed" in the presence of model heteroscedasticity
#' @return Data frame containing commonality partitions for replications.
#' @param ci_sign Character. Sign corresponding to which coefficients should be used for generating error bar for confidence interval. If sign = "+", samples only positive coefficients; if "-", only negative coefficients.
#' @param ci_lower Lower bound of confidence interval.
#' @param ci_upper Upper bound of confidence interval.
#' @param n_replications The number of replications to perform in bootstrap simulation.
#' @param stack_by If "partition", samples from unique and joint effects for commonality partition. If "common", creates confidence interval based on unique vs. common effects.
#'
#' @return Data.frame object containing confidence intervals for each variable.
.helper_make_ci <- function(
                      data,
                      formula,
                      ci_sign = "+",
                      ci_lower = 0.025,
                      ci_upper = 0.975,
                      stack_by = "partition") {
  # get terms from rhs of formula
  formula_terms <- labels(
    terms(
      formula
      )
    )
  message("Bootstrap confidence intervals:")
  if(stack_by == "partition") {
    lapply(1:length(formula_terms),
           function(x) {
             category <- formula_terms[x]
             # collect unique and joint effects for term
             out <- data[stringr::str_detect(
               rownames(data),
               formula_terms[x]
             ),
             ]
             # sample positive effects from bootstrap
             if(
               ci_sign == "+"
             ) {
               out[out<0] <- 0
             } else if (
               # sample negative effects from bootstrap
               ci_sign == "-"
             ) {
               out[out>0] <- 0
             } else {
             }
             out <- colSums(out)
             # produce confidence interval
             lower <- quantile(out, ci_lower)
             upper <- quantile(out, ci_upper)
             out <- data.frame(category, lower, upper)
             print(out)
             return(out)
           }
    ) -> list_CI
  } else if(stack_by == "common") {
    effect_type <- c("Unique", "Common")
    lapply(1:length(effect_type), # sample across unique vs. common effects
           function(x) {
             type <- effect_type[x]
             # collect unique and joint effects for term
             out <- data[stringr::str_detect(
               rownames(data),
               effect_type[x]
             ),
             ]
             # sample positive effects from bootstrap
             if(
               ci_sign == "+"
             ) {
               out[out<0] <- 0
             } else if (
               # sample negative effects from bootstrap
               ci_sign == "-"
             ) {
               out[out>0] <- 0
             } else {
             }
             if(!is.null(dim(out))) out <- colSums(out)
             # produce confidence interval
             lower <- quantile(out, ci_lower)
             upper <- quantile(out, ci_upper)
             out <- data.frame(type, lower, upper)
             out$type <- tolower(out$type)

             print(out)
             return(out)
           }
    ) -> list_CI
  }
  # for each term on rhs of formula:
  # bind confidence intervals for all commonality partitions
  percentile_intervals <- do.call(rbind,
                                  list_CI)
  return(percentile_intervals)
}


