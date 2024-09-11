#' calculate bias in bootstrapped proportions-at-length or -age
#'
#' @description
#' Computes the mean bias in bootstrapped population at length or age compared to original unsampled
#' population at length or age
#'
#' @param sim_props list of replicated abundance at length or age
#' @param og_props original abundance at length or age (computed with data that has not been resampled)
#'
#' @export
#'
bias <- function(sim_props,
                 og_props) {


  sim_props %>%
    tidytable::left_join(og_props) %>%
    tidytable::mutate(bias = sim_FREQ - og_FREQ) %>%
    tidytable::summarise(bias = base::mean(bias), .by = YEAR)


}
