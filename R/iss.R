#' Calculate length or age composition input sampled size (iss)
#'
#' @description
#' Function to calculate length or age composition iss (harmonic mean of realized sample sizes) and add nominal sample
#' size (the number of lengths or ages actually measured) and the number of sampled hauls to output.
#'
#' @param rss iterated length or age composition realized sample size
#' @param freq_data length or age frequency input dataframe
#' @param boot.length Boolean. Resample lengths w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length
#'
#' @return iss
#'
#' @export
#'
iss <- function(rss,
                freq_data,
                boot.length) {

  rss %>%
    tidytable::summarise(iss = psych::harmonic.mean(rss, na.rm = TRUE, zero = FALSE),
                         .by = c(YEAR)) -> .iss

  # add nominal sample size (nss) and number of hauls (nhls). Conditional on length or age.
  if(base::isTRUE(boot.length)){
    .iss %>%
      tidytable::left_join(freq_data %>%
                             tidytable::summarise(SUM_FREQUENCY = n(base::unique(LENGTH)), .by = c(YEAR, HAUL_JOIN, LENGTH)) %>%
                             tidytable::summarise(nss = sum(SUM_FREQUENCY), nhls = length(unique(HAUL_JOIN)), .by = YEAR)) -> iss_out
  }else{
    .iss %>%
      tidytable::left_join(freq_data %>%
                             tidytable::summarise(SUM_FREQUENCY = n(base::unique(AGE)), .by = c(YEAR, HAUL_JOIN, AGE)) %>%
                             tidytable::summarise(nss = sum(SUM_FREQUENCY), nhls = length(unique(HAUL_JOIN)), .by = YEAR)) -> iss_out
  }


return(iss_out)



}
