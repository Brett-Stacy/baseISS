#' Resample hauls w/replacement.
#'
#' @param resampled_trips resampled trips input data table. This is a truncated data table compared to length_DT. It has a column for YEAR, CRUISE, HAUL_JOIN only and one row per unique HAUL_JOIN.
#'
#' @return data table of resampled hauls by year
#'
#' @export
#'
boot_haul = function(resampled_trips) {
  resampled_trips %>%
    tidytable::select(-TRIP_JOIN) %>%
    tidytable::mutate(HAUL_JOIN= sample(HAUL_JOIN, .N, replace = TRUE), .by = YEAR)
}






