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
#' @param stack Character specifying how to stack commonality coefficients. Either NULL for no stacking, "common" to stack unique vs. common effects or "partition" to stack by commonality partition.
#'
#' @return Data.frame object containing confidence intervals for each variable.
.helper_make_ci <- function(
                      data.boot,
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
  # get results from original commonality analysis
  lm_out <- lm(formula = formula, data = data)
  yhat_model <- yhat::regr(lm_out)
  yhat_model_effects <- yhat_model$Commonality_Data$CC


  #tmpList <<- list()

  if(stack == "partition") {
    warning("The process for generating confidence intervals of stacked barplots is experimental and currently under development.\nFor more details see https://github.com/cmndrsn/ggcommonality/issues/15")
    list_CI <- lapply(1:length(formula_terms),
           function(x) {
             category <- formula_terms[x]
             # collect unique and joint effects for term
             out <- data.boot[stringr::str_detect(
               rownames(data.boot),
               formula_terms[x]
             ),,drop=FALSE
             ] |> as.data.frame(drop=FALSE)
             # index resamples matching original commonalities
             # with positive effects
             if(
               sign == "+"
             ) {

               ind_pos <- which(yhat_model_effects[,'Coefficient'] >= 0)
               out <- out[rownames(out) %in% names(ind_pos),]
               #tmpList[[x]] <<- out
             } else if (
               # index resamples matching original commonalities
               # with negative effects
               sign == "-"
             ) {
               ind_neg <- which(yhat_model_effects[,'Coefficient'] <= 0)
               out <- out[rownames(out) %in% names(ind_neg),]
               #tmpList[[x]] <<- out
             } else {
             }
             out <- colSums(out)
             # produce confidence interval
             lower <- quantile(out, ci_bounds[1])
             upper <- quantile(out, ci_bounds[2])
             out <- data.frame(category, lower, upper)
             return(out)
           }
         )
    } else if(stack == "common") {
    warning("The process for generating confidence intervals of stacked barplots is experimental and currently under development.\nFor more details see https://github.com/cmndrsn/ggcommonality/issues/15")
    effect_type <- c("Unique", "Common")
    list_CI <- lapply(1:length(effect_type), # sample across unique vs. common effects
           function(x) {
             type <- effect_type[x]
             # collect unique and joint effects for term
             out <- data.boot[stringr::str_detect(
               rownames(data.boot),
               effect_type[x]
             ),,drop=FALSE
             ] |> as.data.frame(drop=FALSE)
             # sample positive commonality resamples
             if(
               sign == "+"
             ) {
               ind_pos <- which(yhat_model_effects[,'Coefficient'] >= 0)
               out <- out[rownames(out) %in% names(ind_pos),]
               #tmpList[[x]] <<- out
             } else if (
               # sample negative commonality resamples
               sign == "-"
             ) {
               ind_neg <- which(yhat_model_effects[,'Coefficient'] <= 0)
               out <- out[rownames(out) %in% names(ind_neg),]
               #tmpList[[x]] <<- out
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
    )
  }
  # for each term on rhs of formula:
  # bind confidence intervals for all commonality partitions
  percentile_intervals <- do.call(rbind,
                                  list_CI)
  return(percentile_intervals)
}


