#' Resample trips w/replacement.
#'
#' @param freq_data length or age frequency input data frame
#'
#' @return length frequency data table including resampled trips as TRIP_JOIN and associated data
#'
#' @export
#'
boot_trip = function(freq_data) { # based on surveyISS::boot_haul
  freq_data %>%
    tidytable::select(YEAR, TRIP_JOIN) %>% # TRIP_JOIN is "Cruise, Permit, Trip_Seq" pasted together.
    tidytable::distinct() %>%
    tidytable::mutate(TRIP_JOIN = generic_sample(TRIP_JOIN, n.samples = .N), .by = YEAR)
}



