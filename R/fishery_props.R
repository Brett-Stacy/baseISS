#' Resample data and compute proportions-at-length or -age population expansion
#'
#' @description
#' Follows loosely srvy_comps.R from surveyISS package.
#'
#' @param species_code species number code. Used for specific expansion. This is not (yet) an input data filter, it is only for output naming convention and to condition on expansion method.
#' @param area_code area character code. Used for specific expansion. This is not (yet) an input data filter, it is only for output naming convention and to condition on expansion method.
#' @param length_based Boolean. If TRUE, then calculate length iss. if FALSE, then calculate age iss.
#' @param freq_data length or age frequency input data frame
#' @param bin bin size (NULL = 1 cm), also can use custom length bins through defining vector of upper length bin limits, i.e., c(5, 10, 20, 35, 60), plus length group will automatically be populated and denoted with the largest defined bin + 1 (i.e., 61 for provided example)
#' @param plus_len If set at a value, computes length expansion with a plus-length group (default = FALSE)
#' @param minimum_sample_size list(resolution = character string, size = integer). If NULL, then no minimum sample size. If not NULL, The sample size at the chosen resolution (must be column in freq_data, e.g., YAGM_SFREQ for EBS Pcod) for which to filter out data that does not meet the minimum sample size requested. Example: minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30). Note that this filters to keep only samples GREATER than 30 at the YAGM resolution.
#' @param new_trip_N list(type = character ("value", or "proportion"), amount = numeric). If NULL, then the number of trips resampled equals the number actually sampled. If not NULL, then the number of trips is changed by type (acceptable entries are "value", or "proportion") at an amount (acceptable entries are a proportion). E.g., new_trip_N = list(type = "proportion", amount = .50). Only proportion is coded so far as this makes the most sense.
#' @param new_length_N list(type = character ("value", or "proportion"), bound = NULL or character ("minimum", or "maximum") amount = numeric). If NULL, then the number of length samples resampled in a haul equals the number actually sampled. If not NULL, then the haul-level number of samples is changed by type (acceptable entries are "value", or "proportion") at an amount (acceptable entries are an integer number or proportion). E.g., new_length_N = list(type = "value", bound = NULL, amount = 20). The amount can be less than or greater than the true N. Note that if it is either less than or greater than, the minimum of the two is chosen for N (this is still under consideration and may change in the future). The true N is taken to be... DOES THIS ONLY MATTER IF WE NEED A THRESHOLD TO DECIDE WHEN TO TAKE THE MAX?? The samples are still drawn with replacement. Warning: cannot do this if post_strata = "SEX"
#' @param max_length integer or "data_derived" (default). Provides the maximum length bin to record proportions-at-length. Integer values must be equal to or greater than the maximum length observed in the data (this will be changed once a plus-group option is coded in the future). "data_derived" forces the maximum length to be calculated from the data.
#' @param boot.trip Boolean. Resample trips w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length or -age
#' @param boot.haul Boolean. Resample hauls w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length or -age
#' @param boot.length Boolean. Resample lengths w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length
#' @param boot.age Boolean. Resample ages w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-age
#' @param expand.by.sampling.strata expand by observer sampling strata? If TRUE, then an additional weighting factor is calculated and applied to WEIGHT1 based on the number of fish caught in each sampling stratum.
#' @param expansion_factors expansion weighting factors to apply to the proportions. If NULL, then no expansion factors are applied. Otherwise, the conditional options coded in expand_props.R are "haul_numbers" or "haul_numbers" and "month_numbers". Consider improving/generalizing this by calling it expansion_weighting_factors = list(type = c("weight", "number"), factors = c("haul", "area", "month", "gear", etc.) to give the user the option of what aspects (columns) of the data to expand by and do it by weight of fish or number of fish in those categories.
#'
#' @return List of a dataframe of annual population proportions-at-length .lpop.
#'
#' @export
#'
fishery_props <- function(species_code,
                          area_code,
                          length_based = TRUE,
                          freq_data,
                          bin = NULL,
                          plus_len = NULL,
                          minimum_sample_size = NULL,
                          new_trip_N = NULL,
                          new_length_N,
                          max_length,
                          boot.trip = FALSE,
                          boot.haul = FALSE,
                          boot.length = FALSE,
                          boot.age = FALSE,
                          expand.by.sampling.strata = FALSE,
                          expansion_factors)

  {


  # rename to make below code work
  .freq = freq_data



  # randomize trips if boot.trip == true ----
  if(base::isTRUE(boot.trip)) {
    .freq %>%
      boot_trip(new_trip_N = new_trip_N) %>%
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

  # bin and plus group for length if requested ----
  ## bin ----
  if(!is.null(bin)){
    .freq %>%
      bin_length(bin = bin) -> .freq
  }

  ## plus group length ----
  if(!is.null(plus_len)){
    .freq %>%
      plus_length(plus_len = plus_len) -> .freq
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
  .pop = expand_props(species_code = species_code,
                      area_code = area_code,
                      length_based = length_based,
                      freq_data = .freq,
                      minimum_sample_size = minimum_sample_size,
                      max_length = max_length,
                      boot.length = boot.length,
                      expand.by.sampling.strata = expand.by.sampling.strata,
                      expansion_factors = expansion_factors)



  # return as list ----
  # create a useful name based on length or age
  base::ifelse(base::isTRUE(length_based), "length", "age") -> .data_type
  pop_freq = list(.pop)
  names(pop_freq) = .data_type
  return(pop_freq)

}
# for testing ----
# length_DT = .freq

