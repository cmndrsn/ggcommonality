#' Simple Helper Functions for Commonality Barplot
#'
#' Function used for defining the width of individual and common effects
#'
#' Sequence from 1 to 2 by a user-input name.
#' Function applied across an array of values.
#'
#' @param x Numeric. Value or array of values to sequence across.
#'
#' @return List. For each value in x, returns a sequence from 1 to 2 by x.
.helper_seq_from_1_to_2_by = function(x) {
  array(
    sapply(x,
           function(y) {
             seq(from = 1,
                 to = 2,
                 length.out = y + 1)
           }
    )
  )
}

#' Simple Helper Functions for Commonality Barplot
#'
#' Function used to duplicate rows by number of variables.
#' Used when defining common effect bar width.
#'
#' Duplicate the inner values of a sequence.
#'
#' @param nums Numeric array.
#'
#' @return Array.Returns values in nums, with inner values duplicated.
#' @export
.helper_duplicate_inner_values <- function(nums) {
  c(
    min(nums),
    rep(
      nums[min(nums) <
             nums &
             nums <
             max(nums)],
      each = 2),
    max(nums)
  )
}
