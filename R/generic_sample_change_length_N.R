#' Resample with replacement a vector of user-defined length. More generic than simply using base::sample
#'
#' @description
#' Modified generic_sample() function to allow more flexibility based on user-defined options for adjusting haul-level sample size.
#'
#' @param flex.vec flexible (can be length 1) vector of input elements
#' @param new_length_N user-defined sample size adjustment options defined in fishery_iss()
#'
#' @return vector of resampled elements
#'
#' @export
#'
generic_sample_change_length_N = function(flex.vec,
                                          new_length_N = NULL)
  {
  # 0.5.0 case
  flex.vec[base::sample.int(length(flex.vec), size = min(length(flex.vec), new_length_N$amount), replace = TRUE)]

}




