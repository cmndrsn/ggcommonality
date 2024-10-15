#' Plot Commonality Partitions as a Bar Plot in ggplot
#'
#' This function takes a commonality model output from yhat and generates
#' a bar plot based on the unique and common variance shared between variables.
#'
#' @param yhat_model List. Model output of yhat::reg() applied to lm() object.
#'
#' @return ggplot object. Unique and common effects presented as a bar plot.
#' Variance attributable to two variables appears in partition for both.
#' @import ggplot2
#' @import yhat
#' @export
#'
#' @examples
#' data(mtcars)
#' yhat_model_cars <- yhat::regr(
#' lm(
#'   formula = mpg ~ cyl + disp + vs,
#'   data = mtcars
#'   )
#' )
#' ggcommonality(yhat_model_cars)
#'
#' data(trees)
#' yhat_model_trees <- yhat::regr(
#' lm(
#'   formula = Height ~ Girth + Volume + Girth * Volume,
#'   data = trees
#'   )
#' )
#' ggcommonality(yhat_model_trees)
#'
ggcommonality <- function(yhat_model) {
  commonality_df <- df_ggcommonality(yhat_model)
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
     ggplot2::geom_hline(yintercept = 0)+
     ggplot2::theme(axis.text.x = ggplot2::element_blank(),
                    axis.ticks.x = ggplot2::element_blank())+
     ggplot2::labs(x = "Commonality Partition",
          y = "Explained Variance",
          fill = "Variable")
   return(p)

}


