#' Resample with replacement a set of length composition observations of the same length
#'
#' @description
#' Modified base::sample() function to accept n=1 without undesirable treatment:  base::sample() outputs sample(1:n) when n=1 for some reason.
#'
#' @param length_comps vector of length measurements
#' @param n.samples number of samples to resample
#'
#' @return vector of resampled lengths of length n.samples
#'
#' @export
#'
comp_sample = function(length_comps, n.samples) length_comps[base::sample.int(length(length_comps), n = n.samples, replace = TRUE)]




