#' Create tibble for commonality analysis with scatterpie functionality
#'
#' Create dataframe containing information for visualizing 2-dimensional commonality analysis with scatterpie
#'
#' The scatterpie package can be useful for colour-coding commonality coefficients. We can represent commonality
#' coefficients as scatterpies, proportioning each unique and joint effect as a separate pie, such that unique effects receive
#' proportions of 1 in their respective columns, whereas second-order commonalities receive 0.5 in their respective columns, etc.
#'
#' @param formula Formula for linear model from which commonality
#' coefficients will be extracted.
#'
#' @param data  Data.frame object for which analysis will be performed.
#'
#' @returns Data.frame with proportions for each unique and common effect.
#'
#' @export
#'
#' @examples
#' # example with two predictors
#' df_hp <- df_commonality_scatterpie(
#'   hp ~ cyl + disp + wt,
#'   data = mtcars
#' )
#' # example with three predictors
#' df_mpg <- df_commonality_scatterpie(
#'   mpg ~ cyl + disp + wt,
#'   data = mtcars
#' )
#' # merge them together
#' df_joined <- dplyr::left_join(df_hp, df_mpg)
#' # now make scatterpie plot
#' ggplot2::ggplot() +
#'  scatterpie::geom_scatterpie(
#'   ggplot2::aes(
#'     x = var_hp,
#'     y = var_mpg
#'     ),
#'     data = df_joined,
#'     cols = c("cyl", "disp", "wt"))+
#'  ggplot2::coord_fixed()
df_commonality_scatterpie <- function(
    formula,
    data) {
  # fit linear regression model
  mod <-lm(formula, data)
  # extract commonality coefficients
  com <- yhat::regr(mod)
  # get commonalities
  coefs <- com$Commonality_Data$CC
  # make commonality effects into rownames:
  df_coef <- coefs |>
    as.data.frame() |>
    tibble::rownames_to_column("effect") |>
    tibble::tibble()

  # now clean up text output from yhat::regr()
  df_coef$effect <- stringr::str_remove_all(
    df_coef$effect,
    "Unique to |Common to |, and|,") |>
    trimws()
  df_coef$n_cues <- stringr::str_count(df_coef$effect, " ") + 1

  # for each formula predictor, we'll add a new column to the tibble
  new_col_names <- labels(terms(mod))
  # we'll instantiate these with values of 0
  empty_values <- rep(0, times = length(new_col_names))
  # convert to dataframe
  empty_cols <- as.data.frame(t(empty_values))
  names(empty_cols) <- new_col_names
  # now merge new columns
  df_coef <- merge(df_coef, empty_cols)
  # detect column names in row, add 1 where effect present:

  for(this_name in new_col_names) {
    df_coef[stringr::str_detect(df_coef$effect, this_name),
            this_name] <- 1
  }
  # now define proportions based on correct column mapping
  df_coef[,new_col_names] <- df_coef[,new_col_names]/df_coef$n_cues

  # add explicit name for coefficients column
  formula_lhs <- attr(terms(formula), "variables")[[2]]
  coef_col <- paste0("var_", formula_lhs)
  names(df_coef)[names(df_coef) == "Coefficient"] <- coef_col
  # deselect unnecessary columns
  df_coef <- df_coef |>
    dplyr::select(-c("    % Total", "n_cues"))
  # return dataframe
  return(df_coef)
}
# -------------------------------------------------------------------- #
#' Make scatterpie commonality line range plots
#'
#' Create dataframe containing information for visualizing 2-dimensional commonality analysis with scatterpie package
#'
#' @param formula Formula for relevant lm object to be bootstrapped
#'
#' @param data Data.frame object corresponding to formula
#'
#' @param interval Numeric array of 2 values representing confidence
#' interval to be computed. 95% CIs calculated by default
#'
#' @param ... Additional parameters passed to [run_commonality_bootstrap()]
#'
#' @returns Data frame of bootstrapped commonality analysis with appropriate pie chart proportions to represent commonality coefficients
#'
#' @export
.df_ci_commonality <- function(
    formula,
    data,
    interval = c(0.025, .975),
    ...
    ) {
    # convenience function for labeling commonality names
    .clean_commonality_names <- function(x) {
      stringr::str_remove_all(x, "Unique to|Common to|, and|,") |>
        trimws()
    }

    # take label for left-hand side of formula (name of DV)
    label_lhs <- attr(terms(formula), "variables")[[2]]
    # make pie df
    df_pie <- df_commonality_scatterpie(
      formula,
      data = data
    )
    # run bootstrap
    df_bs <- ggcommonality::run_commonality_bootstrap(
      formula,
      data = data,
      ...
  )
  # summarize bootstrap to get 95 percentile interval
  df_ci <- apply(
    df_bs,
    1,
    function(x) quantile(x, interval)
  )
  # make labels for CIs
  # this makes sure DV is included in column name
  # (important for later merges)
  ci_names <- paste0(c("lci_", "uci_"), label_lhs)
  rownames(df_ci) <- ci_names
  # clean names
  colnames(df_ci) <- .clean_commonality_names(colnames(df_ci))
  # format df_ci
  df_ci <- t(df_ci) |>
    as.data.frame() |>
    tibble::rownames_to_column("effect")
  # now merge
  result <- merge(df_pie, df_ci)

  return(result)
}
# -------------------------------------------------------------------- #
#' Make scatterpie commonality line range plots
#'
#' Create dataframe containing information for visualizing 2-dimensional commonality analysis with scatterpie (bootstrap generalization)
#'
#' One way of visualizing commonality effects and their coefficients in
#' a two-dimensional plot is to plot coefficients along with their 95% CIs.
#' However, differentiating effect can be difficult as many explain only
#' a small amount of variance. This function prepares a dataframe which
#' can be used with the scatterpie package in R to colour-code effects
#' Circles are proportioned according to the number of cues involved in
#' the commonality such that the circle is split in half for two-ways
#' commonalities, in thirds for three-way commonalities, etc.
#'
#' @param formulae Array containing two formulae with the same predictors.
#' Normally for linear regression on valence and arousal.
#'
#' @param data Data.frame object corresponding to formula
#'
#' @param interval Numeric array of 2 values representing confidence interval to be computed.
#'
#' @param ... Additional parameters passed to [run_commonality_bootstrap()]
#'
#' @returns Data frame of bootstrapped commonality analysis with appropriate pie chart proportions to represent commonality coefficients
#'
#' @export
#'
#' @examples
#'  df_2d_com <- df_2d_commonality(
#'   c(
#'     mpg ~ cyl + disp + wt,
#'     hp ~ cyl + disp + wt
#'     ),
#'   data = mtcars,
#'   groups = NULL,
#'   n_replications = 100
#' )
#'
#' # create plotting function with scatterpie package
#'
#' df_2d_com |>
#'   dplyr::filter(effect != "Total") |>
#'   ggplot2::ggplot(
#'     ggplot2::aes(x=var_mpg, y=var_hp)
#'     ) +
#'   scatterpie::geom_scatterpie(
#'     ggplot2::aes(
#'       x=var_mpg,
#'        y = var_hp
#'       ), # adjust radius parameter to change circle
#'     cols = c("cyl", "disp", "wt")
#'     )+
#'   ggplot2::geom_linerange(
#'     ggplot2::aes(ymin=lci_hp, ymax=uci_hp)
#'     )+
#'   ggplot2::geom_linerange(
#'     ggplot2::aes(xmin = lci_mpg, xmax = uci_mpg)
#'     )+
#'   ggplot2::coord_equal()
df_2d_commonality <- function(
    formulae,
    data,
    interval = c(0.025, .975),
    ...
) {
  out <- purrr::map(
    formulae,
    function(x) {
      .df_ci_commonality(
        formula=x,
        data=data,
        interval=interval,
        ...
      )
    }
  )
  result <- do.call('merge', out)
}










