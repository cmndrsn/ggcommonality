#' Define XY coordinates for drawing commonality bar plots
#'
#' @param formula Formula passed to regression model
#' @param data data argument matching formula
#' @param stack_by In progress. Currently allows stacking unique and common effects by partition
#' if "partition" is the input. Otherwise it stacks unique vs joint effects.
#' @return List of lists.
#' Lists for positive and negative commonalities.
#' Contained are data.frames for drawing barplot [1] effects and [2] outlines.
#' @import yhat
#' @export
#' @examples
#' data(mtcars)
#' df_ggcommonality(formula = mpg ~ cyl + disp + vs, data = mtcars) |>
#'   suppressWarnings()

df_ggcommonality <- function(formula,
                             data,
                             stack_by = "partition") {

  lm_out <- lm(formula = formula,
               data = data)
  yhat_model <- yhat::regr(lm_out)

  n_pairs <- length(rownames(yhat_model$Commonality_Data$CCTotalbyVar))

  df_yhat_positive <- .helper_format_yhat_commonality(yhat_model, "positive")
  df_yhat_negative <- .helper_format_yhat_commonality(yhat_model, "negative")

  df_positive_split <- .helper_split_partition_effects(df_yhat_positive,
                                splitter = ",",
                                n_pairs = n_pairs)
  df_negative_split <- .helper_split_partition_effects(df_yhat_negative,
                                               splitter = ",",
                                               n_pairs = n_pairs)

  df_positive_pivot <- .helper_pivot_cues_longer(df_positive_split)
  df_negative_pivot <- .helper_pivot_cues_longer(df_negative_split)

 df_positive_xy <- .helper_define_x_coordinates(
   unpivoted_cue_df = df_positive_split,
   pivoted_cue_df = df_positive_pivot,
   stack_by = stack_by,
   x_offset = 1.5)
 df_negative_xy <- .helper_define_x_coordinates(
   unpivoted_cue_df = df_negative_split,
   pivoted_cue_df = df_negative_pivot,
   stack_by = stack_by,
   x_offset = 1.5)

 df_positive_xy <- .helper_define_y_coordinates(df_positive_xy,
                                                stack_by = stack_by)
 df_negative_xy <- .helper_define_y_coordinates(df_negative_xy,
                                                stack_by = stack_by)

 df_positive_outline <- .helper_draw_barplot_outline(df_positive_xy,
                                                     stack_by = stack_by)
 df_negative_outline <- .helper_draw_barplot_outline(df_negative_xy,
                                                     type = "negative",
                                                     stack_by = stack_by)
 barplot_dfs <- list(df_positive_xy,
                     df_positive_outline,
                     df_negative_xy,
                     df_negative_outline)
  return(barplot_dfs)
}
