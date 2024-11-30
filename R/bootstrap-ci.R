.helper_make_ci <- function(formula,
                      data,
                      sample_column,
                      ci_sign = "+",
                      ci_lower = 0.025,
                      ci_upper = 0.975,
                      n_replications = 1000,
                      by = "partition") {
  # get terms from rhs of formula
  formula_terms <- labels(terms(formula)
                          )

  #Run the bootstrap
  comBoot <-run_commonality_bootstrap(formula = formula,
                                      data = data,
                                      groups = sample_column,
                                      n_replications = n_replications)
  if(by == "partition") {
    lapply(1:length(formula_terms),
           function(x) {
             category <- formula_terms[x]
             # collect unique and joint effects for term
             out <- comBoot[stringr::str_detect(
               rownames(comBoot),
               formula_terms[x]
             ),
             ]
             # sample positive effects from bootstrap
             if(
               ci_sign == "+"
             ) {
               out[out<0] <- 0
             } else if (
               # sample negative effects from bootstrap
               ci_sign == "-"
             ) {
               out[out>0] <- 0
             } else {
             }
             out <- colSums(out)
             # produce confidence interval
             lower <- quantile(out, ci_lower)
             upper <- quantile(out, ci_upper)
             out <- data.frame(category, lower, upper)
             return(out)
           }
    ) -> list_CI
  } else {
    effect_type <- c("Unique", "Common")
    lapply(1:length(effect_type), # sample across unique vs. common effects
           function(x) {
             type <- effect_type[x]
             # collect unique and joint effects for term
             out <- comBoot[stringr::str_detect(
               rownames(comBoot),
               effect_type[x]
             ),
             ]
             # sample positive effects from bootstrap
             if(
               ci_sign == "+"
             ) {
               out[out<0] <- 0
             } else if (
               # sample negative effects from bootstrap
               ci_sign == "-"
             ) {
               out[out>0] <- 0
             } else {
             }
             out <- colSums(out)
             # produce confidence interval
             lower <- quantile(out, ci_lower)
             upper <- quantile(out, ci_upper)
             out <- data.frame(type, lower, upper)
             out$type <- tolower(out$type)
             return(out)
           }
    ) -> list_CI
  }
  # for each term on rhs of formula:
  # bind confidence intervals for all commonality partitions
  percentile_intervals <- do.call(rbind,
                                  list_CI)
  return(percentile_intervals)
}


