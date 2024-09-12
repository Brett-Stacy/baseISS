#' Calculate length or age composition realized sampled size (rss)
#'
#' @description
#' Function to calculate rss for length or age composition following McAllister and Ianelli 1997.
#' Follows loosely comp_stats.R rss_length() from surveyISS package.
#'
#' @param sim_props list of replicated abundance at length or age
#' @param og_props original abundance at length or age
#'
#' @export
#'
rss = function(sim_props,
               og_props) {

  sim_props %>%
    tidytable::full_join(og_props) %>%
    tidytable::replace_na(list(sim_FREQ = 0, og_FREQ = 0)) %>%
    tidytable::summarise(rss = base::sum(sim_FREQ * (1 - sim_FREQ)) / base::sum((sim_FREQ - og_FREQ)^2), # when sim_FREQ==og_FREQ, this is zero and dividing by zero for rss returns Inf
                         .by = c(sim, YEAR)) %>%
    tidytable::drop_na()



}

