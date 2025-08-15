#' Preprocessing Functions for Commonality Barplot
#'
#' Format yhat::regr() output for plotting purposes.
#' @noRd
#' @param fitted_model List returned by yhat::regr() function.
#' @param type Character. One of "positive" or "negative".
#' Return positive and negative commonality values from model respectively
#'
#' @return Data.frame object of commonality effects.
#' Formatted in data.frame compatible with commonalitybarplot functions.
#'
.helper_format_yhat_commonality <- function(fitted_model,
                                      type = "positive") {
  fitted_model_formatted <- tibble::rownames_to_column(
    data.frame(
      fitted_model$Commonality_Data$CC)
  )
  names(fitted_model_formatted) <- c("names",
                                     "vals",
                                     "total")
  fitted_model_formatted$names <- trimws(fitted_model_formatted$names)
  fitted_model_formatted$names <- stringr::str_remove_all(
    fitted_model_formatted$names,
    "Unique to |Common to "
  )
  fitted_model_formatted$names <- stringr::str_remove_all(
    fitted_model_formatted$names,
    "and"
  )

  if(type == "positive") {
    fitted_model_formatted <- fitted_model_formatted[
      fitted_model_formatted$vals >0,]
  } else {
    fitted_model_formatted <- fitted_model_formatted[
      fitted_model_formatted$vals <=0,]
  }

  fitted_model_formatted$names <- trimws(fitted_model_formatted$names
                                         )

  unique_names <- c("Total",
    rownames(
      fitted_model$Commonality_Data$CCTotalbyVar
      )
  )

  for(this_name in unique_names
      ) {
    if(! this_name %in%
       fitted_model_formatted$names
       ) {
      this_effect <- data.frame(names = this_name,
                                vals = 0,
                                total = 0
                                )
      fitted_model_formatted <- rbind(fitted_model_formatted,
                                      this_effect
                                      )
    }
  }

  fitted_model_formatted <- subset(fitted_model_formatted,
                                   !names %in% c("Total", "total"))

  return(fitted_model_formatted)
}

#' Preprocessing Functions for Commonality Barplot
#'
#' Expand out data frame so common effects are represented in separate rows.
#' Use regex functions for splitting.
#' @noRd
#' @param plot_data Data.frame with columns "names" and "values".
#' Names column should include a consistent splitter between variable names.
#' @param splitter String pattern used to separate joint effects. E.g., "and"
#' @param n_pairs The number of variable splits to look for.
#'
#' @return Data.frame object.
#'
.helper_split_partition_effects <- function(plot_data,
                                    splitter = ",",
                                    n_pairs) {
  unique_names <- plot_data$names[
    !stringr::str_detect(plot_data$names,
                         splitter)
  ]


  unique_common_effects <- lapply(unique_names,
                              function(this_unique_name) {
                                unfolded_effects <- subset(plot_data,
                                                           stringr::str_detect(
                                                             plot_data$names,
                                                             this_unique_name)
                                )
                                unfolded_effects <- unfolded_effects

                                unfolded_effects$category <- this_unique_name
                                unfolded_effects <- unfolded_effects[
                                  order(unfolded_effects$vals),
                                ]
                                unfolded_effects$plot_order <- factor(
                                  rank(
                                    nchar(
                                      unfolded_effects$names
                                    ),
                                    ties.method = "first"
                                  )
                                )

                                return(unfolded_effects)
                              }
  )
  unique_common_effects <- do.call('rbind',
                                   unique_common_effects
  )
  # separate joint cues into distinct columns
  unfolded_cues <- stringr::str_split_fixed(
    unique_common_effects$names,
    splitter,
    n_pairs
  )

  unique_common_effects <- cbind(unique_common_effects,
                                 unfolded_cues
  )
  unique_common_effects$n_cues <- stringr::str_count(
    unique_common_effects$names,
    splitter
  ) + 1

  unique_common_effects$type <- "common"
  unique_common_effects[unique_common_effects$n_cues == 1,]$type <- "unique"

  return(unique_common_effects)
}

 #' Preprocessing Functions for Commonality Barplot
#'
#' Pivot commonality data.frame longer.
#' @noRd
#' @param partition_effect_df Data.frame returned from .helper_split_partition_effects
#'
#' @return Data.frame with pivoted values.
#'
.helper_pivot_cues_longer <- function(partition_effect_df) {
  pivoted_df <- partition_effect_df |>
    tidyr::pivot_longer(cols = as.character(
      1:max(
        partition_effect_df$n_cues)
    ),
    names_to = "cue") -> pivoted_df

  pivoted_df$value <- trimws(pivoted_df$value)

  pivoted_df <- pivoted_df[pivoted_df$value != "",]
  return(pivoted_df)
}

#' Define X and Y coordinates for building commonality barplot
#'
#' Separate adjacent commonality partitions.
#' @noRd
#' @param pivoted_cue_df Data.frame output from .helper_duplicate_inner_values
#' @param unpivoted_cue_df Data.frame output of .helper_split_partition_effects
#' @param x_offset Numeric. How much to offset adjacent partitions?
#' @param stack_by In progress. Currently allows stacking unique and common effects by partition
#' if "partition" is the input. Otherwise it stacks unique vs joint effects.
#'
#' @return Data.frame object containing x coordinates for commonality.
#'
.helper_define_x_coordinates <- function(pivoted_cue_df,
                                         unpivoted_cue_df,
                                         stack_by = "partition",
                                         x_offset = 1.5) {


  coordinates <- as.data.frame(
    matrix(ncol = 2,
           byrow = TRUE,
           unlist(
             lapply(
               .helper_seq_from_1_to_2_by(
                 unpivoted_cue_df$n_cues
               ),
               .helper_duplicate_inner_values
             )
           )
    )
  )

  names(coordinates) <- c("x_min",
                          "x_max")

  cbind(pivoted_cue_df,
        coordinates) -> pivoted_cue_df

  if(stack_by == "partition") {
  pivoted_cue_df$category_numeric <- as.numeric(
    as.factor(
      pivoted_cue_df$category)
  )
  } else {
    pivoted_cue_df$category_numeric <- as.numeric(
      as.factor(
        pivoted_cue_df$type)
  )
  }

  pivoted_cue_df$x_min <- pivoted_cue_df$x_min + (x_offset *pivoted_cue_df$category_numeric)

  pivoted_cue_df$x_max <- pivoted_cue_df$x_max + (x_offset * pivoted_cue_df$category_numeric)

  return(pivoted_cue_df)

}


#' Define X and Y coordinates for building commonality barplot
#'
#' Incrementally add common effects on top of unique effects.
#' @noRd
#' @param pivoted_cue_df Data.frame output from .helper_define_x_coordinates
#' @param stack_by In progress. Currently allows stacking unique and common effects by partition
#' if "partition" is the input. Otherwise it stacks unique vs joint effects.
#' @return Data.frame containing x a y coordinates for drawing commonalities.
#'
.helper_define_y_coordinates <- function(pivoted_cue_df, stack_by = "partition") {
  if(stack_by != "partition") {
    pivoted_cue_df$plot_order <- as.numeric(
      as.factor(
        pivoted_cue_df$type)
      )
  }
  pivoted_cue_df <- pivoted_cue_df[order(
    pivoted_cue_df$plot_order
  ),
  ]
  pivoted_cue_df <- pivoted_cue_df[order(
    pivoted_cue_df$category
  )
  ,]

  pivoted_cue_df |>
    dplyr::select(category,
                  names,
                  n_cues,
                  type,
                  vals) |>
    dplyr::distinct() -> commonality_effects_df
  if(stack_by != "partition") {
    # grab distinct commonalities for no repeated values
    commonality_effects_df <- commonality_effects_df[!duplicated(
      commonality_effects_df["names"]),]
     pivoted_cue_df <- pivoted_cue_df[!duplicated(
       pivoted_cue_df[c("names", "cue")]),]
    group_var <- commonality_effects_df$type
  } else {
    group_var <- commonality_effects_df$category
  }
  commonality_effects_df$y_min <- ave(commonality_effects_df$vals,
                                      group_var,
                                      FUN= function(x) {
                                        dplyr::lag(
                                          cumsum(
                                            x
                                          )
                                        )
                                      }
  )
  commonality_effects_df$y_max <- ave(commonality_effects_df$vals,
                                      group_var,
                                      FUN= function(x) {
                                        cumsum(
                                          x
                                        )
                                      }
  )
  commonality_effects_df$y_min[is.na(commonality_effects_df$y_min)] <- 0
  commonality_effects_df$y_max[is.na(commonality_effects_df$y_max)] <- 0
  # repeat common effects as many times as there are cues
  # this defines y coordinate for each rectangle
  pivoted_cue_df$y_min <- rep(commonality_effects_df$y_min,
                              times = commonality_effects_df$n_cues)
  pivoted_cue_df$y_max <- rep(commonality_effects_df$y_max,
                              times = commonality_effects_df$n_cues)

  return(pivoted_cue_df)

}

#' Define X and Y coordinates for building commonality barplot
#'
#' Get coordinates for drawing outline of commonality barplot
#' @noRd
#' @param pivoted_cue_df_xy  Data.frame. Output of.helper_define_y_coordinates
#' @param type Positive or negative.
#' @param stack_by In progress. Currently allows stacking unique and common effects by partition
#' if "partition" is the input. Otherwise it stacks unique vs joint effects.
#' Required for plotting positive and negative barplot effects.
#'
#' @return Data.frame object containing outline for commonality bar plot.
#'
.helper_draw_barplot_outline <- function(pivoted_cue_df_xy,
                                         type = "positive",
                                         stack_by = "partition") {
  if(stack_by == "partition") {
    pivoted_cue_df_xy <- pivoted_cue_df_xy |>
      dplyr::group_by(category)
  } else {
    pivoted_cue_df_xy <- pivoted_cue_df_xy |>
      dplyr::group_by(type)
  }
  if(type == "positive") {
    pivoted_cue_df_xy_outline <- pivoted_cue_df_xy |>
      dplyr::summarise(
        y_min = min(y_min),
        y_max = max(y_max),
        x_min = min(x_min),
        x_max = max(x_max),
        x_mid = mean(c(x_min,
                       x_max)
                     )
      )

  } else {
    pivoted_cue_df_xy_outline <- pivoted_cue_df_xy |>
      dplyr::summarise(
        y_min = min(y_max),
        y_max = max(y_min),
        x_min = min(x_min),
        x_max = max(x_max),
        x_mid = mean(c(x_min,
                       x_max)
                     )

      )

  }

  return(pivoted_cue_df_xy_outline)
}
