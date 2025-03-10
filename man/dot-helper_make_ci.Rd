% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bootstrap-ci.R
\name{.helper_make_ci}
\alias{.helper_make_ci}
\title{Generate percentile-based confidence intervals for commonality coefficients}
\usage{
.helper_make_ci(
  formula,
  data,
  sample_column,
  resample_type = "random",
  ci_sign = "+",
  ci_lower = 0.025,
  ci_upper = 0.975,
  n_replications = 1000,
  stack_by = "partition"
)
}
\arguments{
\item{formula}{Formula corresponding to linear regression model}

\item{data}{Data to sample observations from}

\item{sample_column}{Optional column to sample from}

\item{resample_type}{Method for boostrap resampling. Either "random" or "fixed"}

\item{ci_sign}{Character. Sign corresponding to which coefficients should be used for generating error bar for confidence interval. If sign = "+", samples only positive coefficients; if "-", only negative coefficients.}

\item{ci_lower}{Lower bound of confidence interval.}

\item{ci_upper}{Upper bound of confidence interval.}

\item{n_replications}{The number of replications to perform in bootstrap simulation.}

\item{stack_by}{If "partition", samples from unique and joint effects for commonality partition. If "common", creates confidence interval based on unique vs. common effects.}
}
\value{
Data.frame object containing confidence intervals for each variable.
}
\description{
Create random- or fixed-effect percentile-based bootstrap intervals.
}
\author{
Cameron Anderson, Julianne Heitelman
}
