## Defining classes and subclasses:
setClass("Plot")
setClass("Barplot",
         representation(data = "data.frame",
                        formula = "formula",
                        stack_by = "character",
                        n_replications = "numeric",
                        sample_column = "NULL"),
         contains = "Plot"
)
# Declare a generic function

setGeneric("ggcommonality_barplot", function(object) {
  standardGeneric("ggcommonality_barplot")
})
setGeneric("ggcommonality_ci", function(object) {
  standardGeneric("ggcommonality_ci")
})


# Add function as method to Barplot

setMethod("ggcommonality_barplot", signature("Barplot"), function(object) {
    ggcommonality(data = object@data,
                  formula = object@formula,
                  stack_by = object@stack_by)
})
setMethod("ggcommonality_ci", signature("Barplot"), function(object) {
  ci_ggcommonality(data = object@data,
                   formula = object@formula,
                   stack_by = object@stack_by,
                   n_replications = object@n_replications,
                   sample_column = object@sample_column)
})

# make these get defined in function with automatic presets for CI-related arguments

tmp <- new("Barplot",
            data = mtcars,
            formula = cyl ~ mpg + hp + wt,
            stack_by = "common",
            n_replications = 100,
            sample_column = NULL)

ggcommonality_barplot(tmp) +
ggcommonality_ci(tmp)

## classes are defined.
### instances of classes (new above) defined in function based on arguments.
#### classes i need: bootstrap: simulated data should be accessible
####  ci functions should inherit that (or at least return it)


