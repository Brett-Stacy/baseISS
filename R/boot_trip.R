#' Resample trips w/replacement.
#'
#' @param length_DT length frequency input data table.
#'
#' @return length frequency data table including only resampled trips and associated data
#'
#' @export
#'
boot_trip = function(length_DT) { # based on surveyISS::boot_haul
  length_DT %>%
    tidytable::tidytable() %>%
    tidytable::select(YEAR, CRUISE) %>% # change CRUISE to "Cruise, Permit, Trip_Seq" eventually somehow
    tidytable::distinct() %>%
    tidytable::mutate(CRUISE = base::sample(CRUISE, .N, replace = TRUE), .by = YEAR)
}



