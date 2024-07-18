#' calculate bias in bootstrapped proportions-at-length
#'
#' @description
#' Computes the mean bias in bootstrapped population at length compared to original unsampled
#' population at length
#'
#' @param sim_length_props list of replicated abundance at length
#' @param og_length_props original abundance at length (computed with data that has not been resampled)
#'
#' @export
#'
bias_length <- function(sim_length_props,
                        og_length_props) {


  sim_length_props %>%
    tidytable::left_join(og_length_props) %>%
    tidytable::mutate(bias = sim_FREQ - og_FREQ) %>%
    tidytable::summarise(bias = base::mean(bias), .by = YEAR)


}
