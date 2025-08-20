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
#' @param sign Character. Sign corresponding to which coefficients should be used for generating error bar for confidence interval. If sign = "+", samples only positive coefficients; if "-", only negative coefficients.
#' @param ci_bounds Array. Values for lower and upper bounds of confidence interval.
#' @param n_replications The number of replications to perform in bootstrap simulation.
#' @param stack If "partition", samples from unique and joint effects for commonality partition. If "common", creates confidence interval based on unique vs. common effects.
#'
#' @return Data.frame object containing confidence intervals for each variable.
.helper_make_ci <- function(
                      data,
                      formula,
                      sign = "+",
                      ci_bounds = c(0.025, 0.975),
                      stack = "partition") {
  # get terms from rhs of formula
  formula_terms <- labels(
    terms(
      formula
      )
    )

  if(stack == "partition") {
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
               sign == "+"
             ) {
               out[out<0] <- 0
             } else if (
               # sample negative effects from bootstrap
               sign == "-"
             ) {
               out[out>0] <- 0
             } else {
             }
             out <- colSums(out)
             # produce confidence interval
             lower <- quantile(out, ci_bounds[1])
             upper <- quantile(out, ci_bounds[2])
             out <- data.frame(category, lower, upper)

             return(out)
           }
    ) -> list_CI
  } else if(stack == "common") {
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
               sign == "+"
             ) {
               out[out<0] <- 0
             } else if (
               # sample negative effects from bootstrap
               sign == "-"
             ) {
               out[out>0] <- 0
             } else {
             }
             if(!is.null(dim(out))) out <- colSums(out)
             # produce confidence interval
             lower <- quantile(out, ci_bounds[1])
             upper <- quantile(out, ci_bounds[2])
             out <- data.frame(type, lower, upper)
             out$type <- tolower(out$type)


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


