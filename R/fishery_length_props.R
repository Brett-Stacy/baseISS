#' Resample data and compute proportions-at-length population expansion
#'
#' @description
#' Follows loosely srvy_comps.R from surveyISS package.
#' @param lfreq_data  length frequency input dataframe
#' @param yrs any year filter >= (default = NULL)
#' @param boot_thl Boolean. Resample trips, hauls, and lengths w/replacement? (default = FALSE). FALSE will return og proportions-at-length
#'
#' @return List of length number of bootstrap iterations with dataframes of annual population proportions-at-length .lpop.
#'
#' @export
#'
# TESTING:
lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/y2_ebs_pcod_Brett.RDS")
yrs = 2021
boot_thl = TRUE
fishery_length_props <- function(lfreq_data,
                       yrs = NULL,
                       boot_thl = FALSE) {
  # globals ----
  # year switch
  if (is.null(yrs)) yrs <- 0


  # prep data ----
  lfreq_data %>%
    data.table::setDT() %>%
    tidytable::filter(YEAR >= yrs) -> .lfreq


  # randomize trips, hauls, and lengths ----
  if(isTRUE(boot_thl)) {
    # Boot trips (CRUISE for now)
    .lfreq %>%
      boot_trip() -> .r_trips # resampled trips

    .lfreq[, unique(HAUL_JOIN), by = .(YEAR, CRUISE)] %>% # turn og data into a tidytable and condense to the unique YEAR, CRUISE, HAUL_JOIN
      tidytable::rename(HAUL_JOIN = V1) %>% # gives only resampled trips and associated hauls. Hauls are repeated if resampled trips are repeated. ready for boot_haul.
      tidytable::right_join(.r_trips) -> .joined_trips


    # Boot hauls
    .joined_trips %>%
      boot_haul() %>%
      tidytable::mutate(hauljoin_unique = .I) -> .r_hauls # resampled hauls

    .lfreq %>% # Get a DT that looks like og_lf_data but consists only of .r_hauls.
      right_join(.r_hauls) -> .joined_hauls


    # Boot lengths
    .joined_hauls %>%
      boot_length() -> .lfreq # this is intentionally named the same as prior to the conditional statement to be used equivalently in the expanded_length_props() function as a non-bootstrapped data table.

  }


  # calculate population proportions-at-length ----
  .lfreq %>%
      expand_length_props() -> .lpop


  # return as list ----
  list(length = .lpop)

}
