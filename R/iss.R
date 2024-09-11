#' Calculate length or age composition input sampled size (iss)
#'
#' @description
#' Function to calculate length or age composition iss (harmonic mean of realized sample sizes) and add nominal sample
#' size (the number of lengths or ages actually measured) and the number of sampled hauls to output.
#'
#' @param rss iterated length or age composition realized sample size
#' @param freq_data length or age frequency input dataframe
#'
#' @export
#'
iss <- function(rss,
                freq_data) {

  rss %>%
    tidytable::summarise(iss = psych::harmonic.mean(rss, na.rm = TRUE, zero = FALSE),
                         .by = c(YEAR)) %>%
    # add nominal sample size (nss) and number of hauls (nhls)
    tidytable::left_join(freq_data %>%
                           tidytable::summarise(nss = sum(SUM_FREQUENCY), nhls = length(unique(HAUL_JOIN)), .by = YEAR))

}
