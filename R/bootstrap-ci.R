helper_calc_ci <- function(formula,
                      data,
                      sample_column,
                      ci_sign = "positive",
                      samples = 30,
                      replications = 1000){
  # get terms from rhs of formula
  formula_terms <- labels(terms(formula))
  
  # Make the commonality analysis function
  commonality_analysis <- function(...) {
    yhat::regr(
      lm(...)
    )$Commonality_Data$CC[,1]
  }
  
  #Run the bootstrap
  comBoot <- run_structured_bootstrap(dat = data, 
                                      sample_column = sample_column,
                                      samples = samples,
                                      replications = replications,
                                      fnc = commonality_analysis,
                                      replace = T, 
                                      formula = formula)
  
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
             ci_sign == "positive"
           ) {
             out[out<0] <- 0
           } else if (
           # sample negative effects from bootstrap
             ci_sign == "negative"
           ) {
             out[out>0] <- 0
           } else {
           }
           out <- colSums(out)
           # produce confidence interval
           lower <- quantile(out, 0.025)
           upper <- quantile(out, 0.975)
           out <- data.frame(category, lower, upper)
           return(out)
         }
  ) -> list_CI
  # bind confidence intervals for all commonality partitions
  percentile_intervals <- do.call(rbind, list_CI)
  return(percentile_intervals)
}