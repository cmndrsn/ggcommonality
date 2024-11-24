#' Resample Data with Replacement by ID Column
#'
#' @param dat Data.frame object.
#' @param sample_column String. ID column containing values to be sampled with replacement.
#' @param samples Numeric. Number of samples in return data.frame.
#' @param replace Boolean. Sample with replacement?
#' @return Data.frame. Resampled data.
#' @import pbapply
#' @export
#' @author Cameron Anderson
#' @examples
#' .helper_resample_df(subset(df_emosample, expID == 101),
#' sample_column = 'participant',
#' samples = 30,
#' replace = TRUE)
.helper_resample_df <- function(dat,
                        sample_column,
                        samples = 30,
                        replace = TRUE) {

  dat <- data.frame(dat)
  # save 'sample_column' as named column
  sample_column <- as.character(dat[,sample_column])
  dat$sample_column <- sample_column
  # sample from IDs with replacement
  resampled_ids <- sample(
    unique(sample_column),
    size = samples,
    replace = replace
    )
  # for each resampled ID, extract corresponding participant's data
  # save result as list
  lapply(resampled_ids,
         function(x) {
          # print(x)
           resampled_participant_data <- dat[
             which(dat$sample_column == x),]
         }
         ) -> resampled_data
  # collapse across all lists to return 1 data frame
  resampled_df <- do.call(rbind, resampled_data)

  return(resampled_df)
}
#------------------------------------------------------------------------------#
#' Generic Function for Test Statistic
#'
#' @param fnc name of function to use in bootstrap
#' @param ... Optional parameters for fnc
#' @return Output of test function. See details for corresponding help page.
#' @import pbapply
#' @export
#'
#' @examples
#' .helper_apply_test_statistic(fnc = lm,
#' data = subset(df_emosample, expID == 101),
#' formula = arousal ~ arPerf + pitchHeight + mode)
.helper_apply_test_statistic <- function(fnc, ...) {
  fnc(...)
}
#------------------------------------------------------------------------------#

#' Apply User-Specified Test Statistic to Resampled Data
#'
#' Uses ellipsis argument to apply a user-specified function to resampled data.
#'
#' @param dat Data.frame. Data to resample.
#' @param sample_column String. ID column containing values to be sampled with replacement.
#' @param samples Numeric. Number of samples in return data.frame.
#' @param fnc Function. Function to apply to resampled data.
#' @param replace Boolean. Sample with replacement?
#' @param ... Parameters passed to fnc argument.
#' @return Return from function passed to fnc
#' @export
#' @author Cameron Anderson
#' @examples
#' .helper_apply_function_to_random_sample(dat = subset(df_emosample, expID == 101),
#' sample_column = 'participant',
#' samples = 30,
#' fnc = lm,
#' replace = TRUE,
#' formula = valence ~ arousal)
.helper_apply_function_to_random_sample <- function(dat,
                                      sample_column,
                                      samples = 30,
                                      fnc,
                                      replace = TRUE,
                                      ...) {
    .helper_apply_test_statistic(fnc = fnc,
                   data = .helper_resample_df(dat = dat,
                                      sample_column = sample_column,
                                      samples = samples,
                                      replace = replace),
                   ...
                   )

}
#------------------------------------------------------------------------------#

#' Bootstrap Data Using User-Specified Function
#'
#' @param dat Data.frame. Data to resample.
#' @param sample_column String. ID column containing values to be sampled with replacement.
#' @param samples Numeric. Number of samples in return data.frame.
#' @param replications Numeric. Number of times to replicate analysis.
#' @param fnc Function. Function to apply to resampled data.
#' @param replace Boolean. Sample with replacement?
#' @param ... Parameters passed to fnc argument.
#'
#' @return Data.frame object containing output of fnc
#' @import pbapply
#' @export
#' @author Cameron Anderson
#' @examples
#' # Example 1: Bootstrapping linear regression
#' run_structured_bootstrap(dat = df_emosample,
#' sample_column = 'participant',
#' samples = 30,
#' replications = 100,
#' fnc = lm,
#' replace = TRUE,
#' formula = arousal ~ arPerf + rms)
#'
#' # Example 2: User-created function
#' # load in external library (for example)
#' library(yhat)
#' # create a user-specified function to apply in bootstrap
#' commonality_analysis <- function(...) {
#' yhat::regr(lm(...))
#' }
#' # perform bootstrap
#' run_structured_bootstrap(dat = df_emosample,
#' sample_column = 'participant',
#' samples = 30,
#' replications = 100,
#' fnc = commonality_analysis,
#' replace = TRUE,
#' formula = arousal ~ arPerf + rms)
run_structured_bootstrap <- function(dat,
                           sample_column,
                           samples = 30,
                           replications = 100,
                           fnc,
                           replace = TRUE,
                           ...) {
  arguments <- list(...)

  pbapply::pbreplicate(n = replications,
                       expr = .helper_apply_function_to_random_sample(dat = dat,
                               sample_column = sample_column,
                               samples = 30,
                               fnc = fnc,
                               replace = TRUE,
                               arguments)
  )
}
#------------------------------------------------------------------------------#

