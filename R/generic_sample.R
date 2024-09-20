#' Resample with replacement a vector of the same length. More generic than simply using base::sample
#'
#' @description
#' Modified base::sample() function to accept n=1 without undesirable treatment:  base::sample() outputs sample(1:n) when n=1 for some reason.
#'
#' @param flex.vec flexible (can be length 1) vector of input elements
#' @param n.samples number of elements in the return sample
#'
#' @return vector of resampled elements of length n.samples
#'
#' @export
#'
generic_sample = function(flex.vec, n.samples) flex.vec[base::sample.int(length(flex.vec), size = n.samples, replace = TRUE)]




