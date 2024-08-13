#' Resample data and compute proportions-at-length population expansion
#'
#' @description
#' Follows loosely srvy_comps.R from surveyISS package.
#'
#' @param lfreq_data  length frequency input dataframe
#' @param yrs any year filter >= (default = NULL)
#' @param boot.trip Boolean. Resample trips w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length
#' @param boot.haul Boolean. Resample hauls w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length
#' @param boot.length Boolean. Resample lengths w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length
#' @param expand_by_sampling_strata expand by observer sampling strata? If TRUE, then an additional weighting factor is calculated and applied to WEIGHT1 based on the number of fish caught in each sampling stratum.
#' @param expand_using_weighting_factors expand using weighting factors? If TRUE, then then "WEIGHT2" and "WEIGHT4" are applied.
#'
#' @return List of a dataframe of annual population proportions-at-length .lpop.
#'
#' @export
#'
fishery_length_props <- function(lfreq_data,
                       yrs = NULL,
                       boot.trip = FALSE,
                       boot.haul = FALSE,
                       boot.length = FALSE,
                       expand_by_sampling_strata = FALSE,
                       expand_using_weighting_factors = expand_using_weighting_factors)
  {
  # globals ----
  # year switch
  if (is.null(yrs)) yrs <- 0 # when NULL, drop yrs to 0 so it picks up all possible years


  # prep data ----
  lfreq_data %>%
    tidytable::filter(YEAR >= yrs) -> .lfreq



  # randomize trips if boot.trip == true ----
  if(base::isTRUE(boot.trip)) {
    .lfreq %>%
      boot_trip() %>%
      tidytable::mutate(tripjoin_unique = .I) -> .r_trips

    .lfreq %>%
      tidytable::right_join(.r_trips) %>%
      tidytable::rename(tripjoin_orig = "TRIP_JOIN",
                        TRIP_JOIN = "tripjoin_unique") -> .lfreq
  }

  # randomize hauls if boot.haul == true ----
  if(base::isTRUE(boot.haul)) {
    .lfreq %>%
      boot_haul() %>%
      tidytable::mutate(hauljoin_unique = .I) -> .r_hauls

    .lfreq %>%
      tidytable::right_join(.r_hauls) %>%
      tidytable::rename(hauljoin_orig = "HAUL_JOIN",
                        HAUL_JOIN = "hauljoin_unique") -> .lfreq # hauljoin_unique must be renamed to HAUL_JOIN to be generically compatible, i.e., look the same as the original data frame
  }

  # randomize lengths if boot.length == true ----
  if(base::isTRUE(boot.length)) {
    .lfreq %>%
      boot_length() -> .lfreq
  }


# recalculate WEIGHT1 for any combination of conditional statement execution above: WEIGHT1 = proportions at length by haul
  .lfreq %>%
    tidytable::mutate(WEIGHT1 = SUM_FREQUENCY/YAGMH_SFREQ) -> .lfreq





  # ## BEGIN old: bootstrap trips, hauls, lengths as one switch:
  #
  # # randomize trips, hauls, and lengths ----
  # if(isTRUE(boot_thl)) {
  #   # Boot trips
  #   .lfreq %>%
  #     boot_trip() -> .r_trips # resampled trips
  #
  #   .lfreq[, unique(HAUL_JOIN), by = .(YEAR, TRIP_JOIN)] %>% # turn og data into a tidytable and condense to the unique YEAR, CRUISE, HAUL_JOIN
  #     tidytable::rename(HAUL_JOIN = V1) %>% # gives only resampled trips and associated hauls. Hauls are repeated if resampled trips are repeated. ready for boot_haul.
  #     tidytable::right_join(.r_trips) -> .joined_trips
  #
  #
  #   # Boot hauls
  #   .joined_trips %>%
  #     boot_haul() %>%
  #     tidytable::mutate(hauljoin_unique = .I) -> .r_hauls # resampled hauls
  #
  #   .lfreq %>% # Get a DT that looks like og_lf_data but consists only of .r_hauls.
  #     tidytable::right_join(.r_hauls) -> .joined_hauls
  #
  #
  #   # Boot lengths
  #   .joined_hauls %>%
  #     boot_length() -> .lfreq # this is intentionally named the same as prior to the conditional statement to be used equivalently in the expanded_length_props() function as a non-bootstrapped data table.
  #
  # }
  #
  # ## END old


  # calculate population proportions-at-length ----
  .lfreq %>%
      expand_length_props(expand_by_sampling_strata = expand_by_sampling_strata,
                          expand_using_weighting_factors = expand_using_weighting_factors) -> .lpop


  # return as list ----
  list(length = .lpop)

}
# for testing ----
length_DT = .lfreq

