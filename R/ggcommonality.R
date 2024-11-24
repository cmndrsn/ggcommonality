#' Plot Commonality Partitions as a Bar Plot in ggplot
#'
#' This function takes a commonality model output from yhat and generates
#' a bar plot based on the unique and common variance shared between variables.
#'
#' @param formula Formula passed to regression model
#' @param data data argument matching formula
#'
#' @return ggplot object. Unique and common effects presented as a bar plot.
#' Variance attributable to two variables appears in partition for both.
#' @import ggplot2
#' @import yhat
#' @export
#'
#' @examples
#' data(mtcars)
#' ggcommonality(formula = mpg ~ cyl + disp + vs, data = mtcars)
#'
#' data(trees)
#' ggcommonality(formula = Height ~ Girth + Volume + Girth * Volume,
#' data = trees)
#'
ggcommonality <- function(formula,
                          data) {
  commonality_df <- df_ggcommonality(formula,
                                     data)
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
              alpha = 0.7,
              ggplot2::aes(xmin = x_min, xmax = x_max,
                  ymin = y_min, ymax = y_max,
                  fill = value
                  )
              ) +
     ggplot2::geom_rect(data = negative_effects,
              linejoin = "round",
              alpha = 0.7,
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
     ggplot2::geom_hline(yintercept = 0)+
     ggplot2::labs(x = "Commonality Partition",
          y = "Explained Variance\n(Unique + Common)",
          fill = "Variable")

     p <- p +
       # ggplot2::theme_classic()+
       # ggplot2::theme(axis.title.x=ggplot2::element_blank(),
       #                axis.text.x=ggplot2::element_blank(),
       #                axis.ticks.x=ggplot2::element_blank()
       #                ) +
       ggplot2::scale_x_continuous(
                         breaks = positive_outline$x_mid,
                         labels = positive_outline$category
       )

   return(p)
}
#------------------------------------------------------------------------------#
#' Generate percentile-based bootstrap 95% confidence intervals for ggcommonality
#'
#' This function uses structured bootstrapping to create a 95% confidence interval.
#' Specifically, it calls yhat::regr() to generate commonality coefficients for
#' data resampled with replacement. Then it sums unique and joint effects for each
#' commonality partition and generates a 95% confidence interval.
#' By setting ci_sign to "positive" or "negative", you can generate an errorbar
#' for positive and negative commonalities, respectively.
#'
#' @param formula Formula for linear regression model
#' @param data  Data frame matching formula argument
#' @param ... Additional parameters passed to helper_calc_ci()
#' @return ggproto instance
#' @export
#' @examples
#' ggcommonality(formula = mpg ~ cyl + disp + vs,
#' data = mtcars) +
#' ci_ggcommonality(formula = mpg ~ cyl + disp + vs,
#' data = mtcars,
#' sample_column = gear)

ci_ggcommonality <- function(formula,
                          data,
                          ...) {
  commonality_df <- df_ggcommonality(formula,
                                     data)
  lm_out <- lm(formula = formula, data = data)
  yhat_model <- yhat::regr(lm_out)

  n_pairs <- length(rownames(yhat_model$Commonality_Data$CCTotalbyVar))

  positive_effects <- commonality_df[[1]]
  positive_outline <- commonality_df[[2]]
  negative_effects <- commonality_df[[3]]
  negative_outline <- commonality_df[[4]]


  df_ci <- helper_calc_ci(
    formula = formula,
    data = data,
    ...
    )

    positive_outline <- merge(positive_outline, df_ci)


    p <-
      ggplot2::geom_errorbar(data = positive_outline,
                             width = 0.5,
                             color = "grey50",
                             ggplot2::aes(x = x_mid,
                                          ymin = lower,
                                          ymax = upper)
      )


  return(p)
}





