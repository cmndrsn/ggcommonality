## Defining classes and subclasses:
setClass("GGCommonality")


setClass("Bootstrap",
         representation(data = "data.frame",
                        formula = "formula",
                        stack_by = "character",
                        n_replications = "numeric",
                        sample_column = "ANY",
                        resample_type = "character",
                        wild_type = "character",
                        include_total = "ANY",
                        seed = "ANY",
                        ... = "ANY"),
         contains = "GGCommonality"
)


setClass("Barplot",
         representation(data.boot = "matrix",
                        n_replications = "numeric",
                        ... = "ANY"),
         contains = "Bootstrap"
)
# Declare a generic function

setGeneric("ggcommonality_bootstrap", function(object) {
  standardGeneric("ggcommonality_bootstrap")
})
setGeneric("ggcommonality_barplot", function(object) {
  standardGeneric("ggcommonality_barplot")
})
setGeneric("ci_bar", function(object, ...) {
  standardGeneric("ci_bar")
})
setGeneric("ci_box", function(object, ...) {
  standardGeneric("ci_box")
})



# Add function as method to Barplot



setMethod("ggcommonality_bootstrap", signature("Barplot"), function(object) {
  run_commonality_bootstrap(data = object@data,
                formula = object@formula,
                n_replications = object@n_replications,
                groups = object@sample_column,
                resample_type = object@resample_type,
                wild_type = object@wild_type,
                seed = object@seed)
})
setMethod("ggcommonality_barplot", signature("Barplot"), function(object) {
    ggcommonality(data = object@data,
                  formula = object@formula,
                  stack_by = object@stack_by)
})
setMethod("ci_bar", signature("Barplot"), function(object, ...) {
  bs <- run_commonality_bootstrap(data = object@data,
                                  formula = object@formula,
                                  n_replications = object@n_replications,
                                  groups = object@sample_column,
                                  resample_type = object@resample_type,
                                  wild_type = object@wild_type,
                                  seed = object@seed)
  bs <- as.data.frame(bs)
  ci_ggcommonality(data.boot = bs,
                   data = object@data,
                   formula = object@formula,
                   stack_by = object@stack_by,
                   n_replications = object@n_replications,
                   sample_column = object@sample_column,
                   ...)
})
setMethod("ci_box", signature("Barplot"), function(object, ...) {
  bs <- run_commonality_bootstrap(data = object@data,
                                  formula = object@formula,
                                  n_replications = object@n_replications,
                                  groups = object@sample_column,
                                  resample_type = object@resample_type,
                                  wild_type = object@wild_type,
                                  seed = object@seed)
  bs <- as.data.frame(bs)
  plot_coords <- ci_plot_coordinates(data.boot = bs,
                   include_total = object@include_total,
                   data = object@data,
                   formula = object@formula)
  com_linerange(plot_coords)
})

# make these get defined in function with automatic presets for CI-re# make these get defined in function with automatic presets for CI-re# make these get defined in function with automatic presets for CI-related arguments

tmp <- new("Barplot",
            data = mtcars,
            formula = cyl ~ mpg + hp + wt,
            stack_by = "partition",
            n_replications = 100,
            sample_column = NULL,
            resample_type = "wild",
            wild_type = "gaussian",
            include_total = FALSE,
            seed = 1)

gridExtra::grid.arrange(
  ncol = 2,
  ggcommonality_barplot(tmp)+
  ci_bar(tmp, width = 0.5)+
    scale_fill_viridis_d(),
  ci_box(tmp)+
    scale_fill_viridis_d()+
    coord_flip()
)
