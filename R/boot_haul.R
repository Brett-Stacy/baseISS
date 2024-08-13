#' Resample hauls w/replacement.
#'
#' @param length_DT length frequency input data table. Can be the output object from boot_trip() if boot.trip == true
#'
#' @return length frequency data table including resampled hauls as HAUL_JOIN and associated data
#'
#' @export
#'
boot_haul = function(length_DT) { # based on surveyISS::boot_haul
  length_DT %>%
    tidytable::select(YEAR, TRIP_JOIN, HAUL_JOIN) %>%
    tidytable::distinct() %>%
    tidytable::mutate(HAUL_JOIN = generic_sample(HAUL_JOIN, n.samples = .N), .by = c(YEAR, TRIP_JOIN))
}






