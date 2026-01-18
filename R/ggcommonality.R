#' Plot Commonality Partitions as a Bar Plot in ggplot
#'
#' This function takes a commonality model output from yhat and generates
#' a bar plot based on the unique and common variance shared between variables.
#' @param formula Formula passed to regression model
#' @param data data argument matching formula
#' @param stack Character specifying how to stack commonality coefficients. Either NULL for no stacking, "common" to stack unique vs. common effects or "partition" to stack by commonality partition.
#' @return ggplot object. Unique and common effects presented as a bar plot.
#' Variance attributable to two variables appears in partition for both.
#' @import ggplot2
#' @import yhat
#' @noRd
.plot_ggcommonality <- function(formula,
                          data,
                          stack = "partition") {
  commonality_df <- .df_ggcommonality(formula,
                                     data,
                                     stack = stack)
  lm_out <- lm(formula = formula, data = data)
  yhat_model <- yhat::regr(lm_out)

  n_pairs <- length(rownames(yhat_model$Commonality_Data$CCTotalbyVar))

  positive_effects <- commonality_df[[1]]
  positive_outline <- commonality_df[[2]]
  negative_effects <- commonality_df[[3]]
  negative_outline <- commonality_df[[4]]

   p <- ggplot2::ggplot()+
     ggplot2::geom_rect(data = positive_effects,
              linejoin = "round",
              ggplot2::aes(xmin = x_min, xmax = x_max,
                  ymin = y_min, ymax = y_max,
                  fill = value
                  )
              ) +
     ggplot2::geom_rect(data = negative_effects,
              linejoin = "round",
              ggplot2::aes(xmin = x_min,
                 xmax = x_max,
                 ymin = y_min,
                 ymax = y_max,
                 fill = value
                 )
             ) +
     ggplot2::geom_linerange(data = positive_outline,
                             ggplot2::aes(x = x_min,
                               ymin = y_min,
                               ymax = y_max)
                    ) +
     ggplot2::geom_linerange(data = positive_outline,
                             ggplot2::aes(x = x_max,
                            ymin = y_min,
                            ymax = y_max)
                        ) +
     ggplot2::geom_linerange(data = positive_outline,
                             ggplot2::aes(y = y_min,
                            xmin = x_min,
                            xmax = x_max)
                        ) +
     ggplot2::geom_linerange(data = positive_outline,
                             ggplot2::aes(y = y_max,
                            xmin = x_min,
                            xmax = x_max)
                        ) +
     ggplot2::geom_linerange(data = negative_outline,
                             ggplot2::aes(x = x_min,
                            ymin = 0,
                            ymax = y_min)) +
     ggplot2::geom_linerange(data = negative_outline,
                             ggplot2::aes(x = x_max,
                            ymin = 0,
                            ymax = y_min)) +
     ggplot2::geom_linerange(data = negative_outline,
                             ggplot2::aes(x = x_max,
                            ymin = y_min,
                            ymax = y_max)) +
     ggplot2::geom_linerange(data = negative_outline,
                             ggplot2::aes(y = y_min,
                            xmin = x_min,
                            xmax = x_max)
                        ) +
     ggplot2::geom_linerange(data = positive_effects,
                             alpha = 0.5,
                             ggplot2::aes(y = y_min,
                                          group = names,
                                          xmin = x_min,
                                          xmax = x_max)
     ) +
     ggplot2::geom_linerange(data = negative_effects,
                             alpha = 0.5,
                             ggplot2::aes(y = y_min,
                                          group = names,
                                          xmin = x_min,
                                          xmax = x_max)
     ) +
     ggplot2::labs(x = "Commonality Partition",
          y = "Explained Variance\n(Unique + Common)",
          fill = "Variable")
   if(stack == "partition") {
     p <- p +
       ggplot2::scale_x_continuous(
         breaks = positive_outline$x_mid,
         labels = positive_outline$category
       )
   } else {
     p <- p +
       ggplot2::scale_x_continuous(
         breaks = positive_outline$x_mid,
         labels = positive_outline$type
       )
   }

   return(p)
}

#------------------------------------------------------------------------------#
#'
#' Percentile-based Bootstrap Confidence Intervals for ggcommonality.
#'
#' Uses structured bootstrapping to create a 95% confidence interval.
#'
#' Calls yhat::regr() to generate commonality coefficients for
#' data resampled with replacement. Then it sums unique and joint effects for each
#' commonality partition and generates a 95% confidence interval.
#' By setting sign to "positive" or "negative", you can generate an errorbar
#' for positive and negative commonalities, respectively.
#' @param formula Formula for linear regression model
#' @param data  Data frame matching formula argument
#' @param sample_column Character. Name of column for resampling observations. If blank, simple resampling is performed.
#' @param n_replications Numeric. Number of replications to use in bootstrap.
#' @param sign If "+", genereates confidence intervals using only positive coefficients
#' If "-", generates confidence intervals using only negative coefficients.
#' Otherwise, generates confidence interval using both positive and negative.
#' @param ci_bounds Array. Values for lower and upper bounds of confidence interval.
#' @param stack Character specifying how to stack commonality coefficients. Either NULL for no stacking, "common" to stack unique vs. common effects or "partition" to stack by commonality partition.
#' @param resample_type Method for boostrap resampling. Either "random", "fixed", or "wild".
#' @param wild_type If resample_type == "wild", either "Gaussian" to
#' multiply resampled residuals by random constants from the normal distribution,
#' or sign to randomly multiply half of the residuals by +1 and half by -1.
#' This provides a solution to "fixed" in the presence of model heteroscedasticity
#' @return Data frame containing commonality partitions for replications.
#' @param ... Additional parameters passed to ggplot2::geom_errorbar
#' @import pbapply
#' @noRd
.ci_ggcommonality <- function(
                          data.boot,
                          formula,
                          data,
                          sign = "+",
                          ci_bounds = c(0.025, 0.975),
                          stack = "partition",
                          ...) {


  # if groups argument is not explicitly stated, set value to NULL
  # when passed to mosaic::resample

  commonality_df <- .df_ggcommonality(formula,
                                     data,
                                     stack = stack)
  lm_out <- lm(formula = formula, data = data)
  yhat_model <- yhat::regr(lm_out)

  n_pairs <- length(rownames(yhat_model$Commonality_Data$CCTotalbyVar))

  positive_effects <- commonality_df[[1]]
  positive_outline <- commonality_df[[2]]
  negative_effects <- commonality_df[[3]]
  negative_outline <- commonality_df[[4]]


  df_ci <-
    .helper_make_ci(
      data.boot = data.boot,
      data = data,
      formula = formula,
      sign = sign,
      ci_bounds = ci_bounds,
      stack = stack
    )

    positive_outline <- merge(positive_outline, df_ci)


    p <-
      ggplot2::geom_errorbar(data = positive_outline,
                             mapping = ggplot2::aes(x = x_mid,
                                          ymin = lower,
                                          ymax = upper),
                             ...
      )


  return(p)
}





