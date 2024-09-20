#' Resample data and compute proportions-at-length or -age population expansion
#'
#' @description
#' Follows loosely srvy_comps.R from surveyISS package.
#'
#' @param length_based Boolean. If TRUE, then calculate length iss. if FALSE, then calculate age iss.
#' @param freq_data length or age frequency input data frame
#' @param yrs any year filter >= (default = NULL)
#' @param boot.trip Boolean. Resample trips w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length or -age
#' @param boot.haul Boolean. Resample hauls w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length or -age
#' @param boot.length Boolean. Resample lengths w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length
#' @param boot.age Boolean. Resample ages w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-age
#' @param expand.by.sampling.strata expand by observer sampling strata? If TRUE, then an additional weighting factor is calculated and applied to WEIGHT1 based on the number of fish caught in each sampling stratum.
#' @param expand_using_weighting_factors expand using weighting factors? If TRUE, then then "WEIGHT2" and "WEIGHT4" are applied.
#'
#' @return List of a dataframe of annual population proportions-at-length .lpop.
#'
#' @export
#'
fishery_props <- function(length_based,
                          freq_data,
                          yrs = NULL,
                          boot.trip = FALSE,
                          boot.haul = FALSE,
                          boot.length = FALSE,
                          boot.age = FALSE,
                          expand.by.sampling.strata = FALSE,
                          expand_using_weighting_factors = TRUE)

  {
  # globals ----
  # year switch
  if (is.null(yrs)) yrs <- 0 # when NULL, drop yrs to 0 so it picks up all possible years


  # prep data ----
  freq_data %>%
      tidytable::filter(YEAR >= yrs) -> .freq # filters for only years requested and forces freq_data into a tidytable format



  # randomize trips if boot.trip == true ----
  if(base::isTRUE(boot.trip)) {
    .freq %>%
      boot_trip() %>%
      tidytable::mutate(tripjoin_unique = .I) -> .r_trips

    .freq %>%
      tidytable::right_join(.r_trips) %>%
      tidytable::rename(tripjoin_orig = "TRIP_JOIN",
                        TRIP_JOIN = "tripjoin_unique") -> .freq
  }

  # randomize hauls if boot.haul == true ----
  if(base::isTRUE(boot.haul)) {
    .freq %>%
      boot_haul() %>%
      tidytable::mutate(hauljoin_unique = .I) -> .r_hauls

    .freq %>%
      tidytable::right_join(.r_hauls) %>%
      tidytable::rename(hauljoin_orig = "HAUL_JOIN",
                        HAUL_JOIN = "hauljoin_unique") -> .freq # hauljoin_unique must be renamed to HAUL_JOIN to be generically compatible, i.e., look the same as the original data frame
  }

  # randomize lengths if boot.length == true ----
  if(base::isTRUE(boot.length)) {
    .freq %>%
      boot_length() -> .freq
  }

  # resample different length N at haul level if requested ----
  if(base::isTRUE(boot.length) & !base::is.null(new_length_N)){
    .freq %>%
      reboot_length_N(new_length_N = new_length_N) -> .freq
  }

  # randomize ages if boot.age == true ----
  if(base::isTRUE(boot.age)) {
    .freq %>%
      boot_age() -> .freq
  }




  # recalculate WEIGHT1 for any combination of conditional statement execution above: WEIGHT1 = proportions at length or age by haul
  if(base::isFALSE(length_based) & base::isFALSE(boot.age)){ # og age props where boot.age = FALSE. WEIGHT1 needs to be calculated initially for length
    .freq %>% # need to revisit this for conditional age at length as SUM_FREQUENCY will for ages will be different if we consider their lengths
      tidytable::summarise(SUM_FREQUENCY = n(base::unique(AGE)), .by = c(YEAR, HAUL_JOIN, AGE)) %>% # summarising excludes any irrelevant columns, add those back in with left_join below.
      tidytable::mutate(YH_SFREQ = base::sum(SUM_FREQUENCY), .by = c(YEAR, HAUL_JOIN)) %>% # YH_SFREQ is analagous to YAGMH_SFREQ for length
      tidytable::mutate(WEIGHT1 = SUM_FREQUENCY/YH_SFREQ) %>% # same WEIGHT1 calculation method as length
      tidytable::left_join(.freq %>% # add the missing columns back in, using the distinct function to avoid unwanted row replication.
                             tidytable::distinct()) -> .freq
  }else if(base::isTRUE(boot.age)){ # resampled age props where boot.age = TRUE
    .freq %>%
      tidytable::mutate(YH_SFREQ = base::sum(SUM_FREQUENCY), .by = c(YEAR, HAUL_JOIN)) %>%
      tidytable::mutate(WEIGHT1 = SUM_FREQUENCY/YH_SFREQ) -> .freq
  }else if(base::isTRUE(boot.length)){ # length resampled data. WEIGHT1 already exists but needs to be recalculated for resampled data.
    .freq %>%
      tidytable::mutate(WEIGHT1 = SUM_FREQUENCY/YAGMH_SFREQ) -> .freq
  }





  # calculate population proportions-at-length or -age ----
  .freq %>%
      expand_props(species_code = species_code,
                   area_code = area_code,
                   boot.length = boot.length,
                   expand.by.sampling.strata = expand.by.sampling.strata,
                   expand_using_weighting_factors = expand_using_weighting_factors) -> .pop


  # return as list ----
  # create a useful name based on length or age
  base::ifelse(base::isTRUE(length_based), "length", "age") -> .data_type
  pop_freq = list(.pop)
  names(pop_freq) = .data_type
  return(pop_freq)

}
# for testing ----
# length_DT = .freq

