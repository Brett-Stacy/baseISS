#' Resample trips w/replacement.
#'
#' @param length_DT length frequency input data table.
#'
#' @return length frequency data table including resampled trips as TRIP_JOIN and associated data
#'
#' @export
#'
boot_trip = function(length_DT) { # based on surveyISS::boot_haul
  length_DT %>%
    tidytable::select(YEAR, TRIP_JOIN) %>% # TRIP_JOIN is "Cruise, Permit, Trip_Seq" pasted together.
    tidytable::distinct() %>%
    tidytable::mutate(TRIP_JOIN = generic_sample(TRIP_JOIN, n.samples = .N), .by = YEAR)
}



