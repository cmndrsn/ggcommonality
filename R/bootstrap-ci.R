.helper_make_ci <- function(formula,
                      data,
                      sample_column,
                      ci_sign = "+",
                      ci_lower = 0.025,
                      ci_upper = 0.975,
                      n_replications = 1000) {
  # get terms from rhs of formula
  formula_terms <- labels(terms(formula)
                          )

  #Run the bootstrap
  comBoot <-run_commonality_bootstrap(formula = formula,
                                      data = data,
                                      groups = sample_column,
                                      n_replications = n_replications)
  # for each term on rhs of formula:
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
  # bind confidence intervals for all commonality partitions
  percentile_intervals <- do.call(rbind,
                                  list_CI)
  return(percentile_intervals)
}


