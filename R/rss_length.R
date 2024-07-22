#' Calculate length composition realized sampled size (rss)
#'
#' @description
#' Function to calculate rss for length composition following McAllister and Ianelli 1997.
#' Follows loosely comp_stats.R rss_length() from surveyISS package.
#'
#' @param sim_length_props list of replicated abundance at length
#' @param og_length_props original abundance at length
#'
#' @export
#'
rss_length = function(sim_length_props,
                      og_length_props) {

  sim_length_props %>%
    tidytable::full_join(og_length_props) %>%
    tidytable::replace_na(list(sim_FREQ = 0, og_FREQ = 0)) %>%
    tidytable::summarise(rss = base::sum(sim_FREQ * (1 - sim_FREQ)) / base::sum((sim_FREQ - og_FREQ)^2),
                         .by = c(sim, YEAR)) %>%
    tidytable::drop_na()



}

