#' Title
#'
#' @slot data data.frame.
#' @slot data.boot matrix.
#' @slot formula formula.
#' @slot stack ANY.
#' @slot stack_by character.
#' @slot n_replications numeric.
#' @slot sample_column ANY.
#' @slot resample_type character.
#' @slot wild_type character.
#' @slot include_total ANY.
#' @slot seed ANY.
#' @slot ... ANY.
#'
#' @returns
#' @export
#'
#' @examples
methods::setClass("GGCommonality",
         representation(data = "data.frame",
                        data.boot = "matrix",
                        formula = "formula",
                        stack = "ANY",
                        stack_by = "character",
                        n_replications = "numeric",
                        sample_column = "ANY",
                        resample_type = "character",
                        wild_type = "character",
                        include_total = "ANY",
                        seed = "ANY",
                        ... = "ANY"),
)



# Declare a generic function

methods::setGeneric("boot_commonality", function(x) {
  standardGeneric("boot_commonality")
})
# setGeneric("plot", function(x) {
#   standardGeneric("plot")
# })
methods::setGeneric("add_ci", function(x, ...) {
  standardGeneric("add_ci")
})


# Add function as method to GGCommonality

methods::setMethod("boot_commonality", signature("GGCommonality"), function(x) {
  run_commonality_bootstrap(
    data = x@data,
    formula = x@formula,
    n_replications = x@n_replications,
    groups = x@sample_column,
    resample_type = x@resample_type,
    wild_type = x@wild_type,
    seed = x@seed
  )
})
methods::setMethod("plot", signature("GGCommonality"), function(x) {
    if(x@stack == FALSE) {
      plot_coords <- ci_plot_coordinates(
        data.boot = x@data.boot,
        include_total = x@include_total,
        data = x@data,
        formula = x@formula)
        plot_com_unstacked(plot_coords)
    } else {
    ggcommonality(data = x@data,
                  formula = x@formula,
                  stack_by = x@stack_by)
    }
})
methods::setMethod("add_ci", signature("GGCommonality"), function(x, ...) {
  if(x@stack == FALSE) {
    plot_coords <- ci_plot_coordinates(
      data.boot = x@data.boot,
      include_total = x@include_total,
      data = x@data,
      formula = x@formula
    )

      com_unstacked_errorbar(plot_coords, ...)

  } else {
    ci_ggcommonality(
      data.boot = x@data.boot,
      data = x@data,
      formula = x@formula,
      stack_by = x@stack_by,
      ...
    )
  }
})

plot_commonality <- function(
    data,
    formula,
    add_ci = TRUE,
    stack = FALSE,
    stack_by = "common",
    n_replications = 100,
    sample_column = NULL,
    resample_type = "wild",
    wild_type = "gaussian",
    include_total = FALSE,
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
      stack_by = stack_by,
      n_replications = n_replications,
      sample_column = sample_column,
      resample_type = resample_type,
      wild_type = wild_type,
      include_total = include_total,
      seed = seed
      )

}
