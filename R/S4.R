#' Visualizing commonality analyses
#'
#' S4 class for defining ggcommonality analysis objects.
#'
#' @slot data Data.frame object containing data to be visualized.
#' @slot data.boot Matrix of bootstrapped data used to generate confidence interval.
#' @slot formula formula. Formula representing equation for linear regression model.
#' @slot stack Character specifying how to stack commonality coefficients. Either NULL for no stacking, "common" to stack unique vs. common effects or "partition" to stack by commonality partition.
#' @slot n_replications numeric. Number of bootstrap replications.
#' @slot sample_column ANY. Column to resample from in bootstrap.
#' @slot resample_type character. Character vector specifying whether resampling should be fixed or random. See details.
#' @slot wild_type character.If resample_type == "wild", either "Gaussian" to
#' multiply resampled residuals by random constants from the normal distribution,
#' or sign to randomly multiply half of the residuals by +1 and half by -1.
#' This provides a solution to "fixed" in the presence of model heteroscedasticity
#' @slot include_total ANY. TRUE or FALSE, specifying whether to include bar representing total explained variance.
#' @slot seed ANY. Number specifying which seed to set R's random number generator to.
#' @slot ci_bounds ANY.
#' @slot ... ANY.
#'
#' @return Data frame containing commonality partitions for replications.
#' @returns List with results from yhat::regr commonality analysis summary
#' @export
#'
#' @examples
methods::setClass("GGCommonality",
         representation(data = "data.frame",
                        data.boot = "matrix",
                        formula = "formula",
                        stack = "ANY",
                        n_replications = "numeric",
                        sample_column = "ANY",
                        resample_type = "character",
                        wild_type = "character",
                        include_total = "ANY",
                        ci_bounds = "ANY",
                        seed = "ANY",
                        ... = "ANY"),
)

#' Get results from yhat package's commonality analysis function
#'
#' Results from yhat for commonality analysis.
#'
#' @param x GGCommonality object
#'
#' @returns ggproto object
#' @export
#'
methods::setGeneric("ggcom_yhat", function(x) {
  standardGeneric("ggcom_yhat")
})

# Print and plot confidence interval generated for GGCommonality object

#' Flexibly plots confidence interval for GGCommonality objects based on percentile-based bootstrapping using ggplot2
#'
#' @param x GGCommonality object
#' @param ... Other ggplot2 parameters
#' @rdname ggcom-ci
#' @aliases ggcom_ci
#' @returns
#' @export
#'
methods::setGeneric("ggcom_ci", function(x, ...) {
  standardGeneric("ggcom_ci")
})
#' Helper function for ggcom_ci
#'
#' Plots commonality analysis confidence intervals from bootstrap simulations
#'
#' @noRd
#' @param x GGCommonality object
#' @param ... Other ggplot2 parameters
#'
#' @returns
#' @export
#'
methods::setGeneric(".ggcom_ci_stacked", function(x, ...) {
  standardGeneric(".ggcom_ci_stacked")
})

methods::setMethod("ggcom_yhat", signature("GGCommonality"), function(x) {
  list(
    yhat =
  yhat::regr(
    lm(
      data = x@data,
      formula = x@formula
    )
  ),
  ci = apply(
    x@data.boot,
    1,
    function(y) quantile(y, x@ci_bounds)
    )
  )
})

#' Helper function for ggcom_ci
#'
#' Plots commonality analysis confidence intervals from bootstrap simulations
#'
#' @noRd
#' @param x A GGCommonality class object
#' @export
methods::setMethod(".ggcom_ci_stacked", signature("GGCommonality"), function(x, ...) {
  message("Bootstrapped confidence intervals:")
  if(is.null(x@stack)) .ggcom_ci_stacked <- .ci_plot_coordinates(
    data.boot = x@data.boot,
    include_total = x@include_total,
    data = x@data,
    formula = x@formula,
    ci_bounds = x@ci_bounds
  )[,c('com', 'lci', 'uci')] |> distinct()
  else .ggcom_ci_stacked <-
      .helper_make_ci(
        data.boot = x@data.boot,
        data = x@data,
        formula = x@formula,
        ci_bounds = x@ci_bounds,
        stack = x@stack
      )
  print(.ggcom_ci_stacked)
})

#' Plot commonality analyses
#'
#' Plots commonality analysis confidence intervals from bootstrap simulations
#'
#' @param x A GGCommonality class object
#' @rdname plot-ggcommonality
#' @aliases plot.ggcommonality
#' @export
methods::setMethod("plot", signature("GGCommonality"), function(x) {
    if(is.null(x@stack)) {
      plot_coords <- .ci_plot_coordinates(
        data.boot = x@data.boot,
        include_total = x@include_total,
        data = x@data,
        ci_bounds = x@ci_bounds,
        formula = x@formula)
        .plot_com_unstacked(plot_coords)
    } else {
    .plot_ggcommonality(data = x@data,
                  formula = x@formula,
                  stack = x@stack)
    }
})

#' Create confidence interval for ggcommonality object
#'
#' This method plots a ggcommonality object
#'
#' @param x A GGCommonality class object
#' @param width Width argument passed to ggplot2 to define confidence interval appearance
#' @param ... Other arguments passed to ggprotos from ggplot2
#' @rdname plot-ggcommonality
#' @aliases ggcom_ci
#' @export
methods::setMethod("ggcom_ci", signature("GGCommonality"),
   function(x, width = 0.3, ...) {
     .ggcom_ci_stacked(x, ...)
    if(is.null(x@stack)) {
      plot_coords <- .ci_plot_coordinates(
        data.boot = x@data.boot,
        include_total = x@include_total,
        data = x@data,
        formula = x@formula,
        ci_bounds = x@ci_bounds
      )

        .com_unstacked_errorbar(plot_coords, width = width, ...)

    } else {

      .ci_ggcommonality(
        data.boot = x@data.boot,
        data = x@data,
        formula = x@formula,
        stack = x@stack,
        ci_bounds = x@ci_bounds,
        width = width,
        ...
      )
    }
})


#' Object for plotting commonality analyses
#'
#' Function for defining ggcommonality object
#'
#' @param data Data.frame object containing data to be visualized
#' @param formula Formula in form of y ~ x1 + x2
#' @param stack Character specifying how to stack commonality coefficients. Either NULL for no stacking, "common" to stack unique vs. common effects or "partition" to stack by commonality partition.
#' @param n_replications Numeric. Number of replications for bootstrap simulation.
#' @param sample_column Character. Name of column to perform stratified sampling with, or leave as NULL
#' @param resample_type Character. Method for boostrap resampling. Either "random", "fixed", or "wild". See README for details.
#' @param wild_type Character. If resample_type == "wild", either "Gaussian" to
#' multiply resampled residuals by random constants from the normal distribution,
#' or sign to randomly multiply half of the residuals by +1 and half by -1.
#' This provides a solution to "fixed" in the presence of model heteroscedasticity. See README for details
#' @param include_total Logical. Include bar representing total variance explained across all unique and common effects?
#' @param seed Numeric. Number to set R's randomization seed to for reproducibility.
#' @param ci_bounds Array. Values representing lower and upper bounds of confidence intervals.
#' @param add_ci Boolean. Add confidence interval generated from bootstrapping?
#'
#' @returns
#' @export
#'
#' @examples
ggcom <- function(
    formula,
    data,
    add_ci = TRUE,
    stack = NULL,
    n_replications = 100,
    sample_column = NULL,
    resample_type = "wild",
    wild_type = "gaussian",
    include_total = FALSE,
    ci_bounds = c(0.025, 0.975),
    seed = NULL
    ) {

  if(add_ci) {
    bs <- run_commonality_bootstrap(data = data,
                                    formula = formula,
                                    n_replications = n_replications,
                                    groups = sample_column,
                                    resample_type = resample_type,
                                    wild_type = wild_type,
                                    seed = seed)
  } else {
    bs <- NULL
  }


  methods::new("GGCommonality",
      data = data,
      data.boot = bs,
      formula = formula,
      stack = stack,
      n_replications = n_replications,
      sample_column = sample_column,
      resample_type = resample_type,
      wild_type = wild_type,
      include_total = include_total,
      ci_bounds = ci_bounds,
      seed = seed
      )

}
