#' calculate bias in bootstrapped length composition
#'
#' @description
#' Computes the mean bias in bootstrapped population at length compared to original unsampled
#' population at length
#'
#' @param r_length iterated population at length
#' @param ogl original population at length without any sampling
#'
#' @export
#'
bias_length <- function(r_length,
                        ogl) {
