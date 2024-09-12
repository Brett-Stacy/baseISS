#' Resample hauls w/replacement.
#'
#' @param freq_data length or age frequency input data frame. Can be the output object from boot_trip() if boot.trip == true
#'
#' @return length frequency data table including resampled hauls as HAUL_JOIN and associated data
#'
#' @export
#'
boot_haul = function(freq_data) { # based on surveyISS::boot_haul
  freq_data %>%
    tidytable::select(YEAR, TRIP_JOIN, HAUL_JOIN) %>%
    tidytable::distinct() %>%
    tidytable::mutate(HAUL_JOIN = generic_sample(HAUL_JOIN, n.samples = .N), .by = c(YEAR, TRIP_JOIN))
}






