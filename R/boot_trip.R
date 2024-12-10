#' Resample trips w/replacement, changing the number of trips if desired
#'
#' @param freq_data length or age frequency input data frame
#' @param new_trip_N user-defined sample size adjustment options defined in fishery_iss()
#'
#' @return frequency data table including resampled trips as TRIP_JOIN and associated data
#'
#' @export
#'
boot_trip = function(freq_data,  # based on surveyISS::boot_haul
                     new_trip_N = NULL)
  {

  freq_data %>%
    tidytable::select(YEAR, TRIP_JOIN) %>% # TRIP_JOIN is "Cruise, Permit, Trip_Seq" pasted together.
    tidytable::distinct() -> .condensed.trip
    if(base::is.null(new_trip_N)){
      .condensed.trip %>%
      tidytable::mutate(TRIP_JOIN = generic_sample(TRIP_JOIN,
                                                   n.samples = .N),
                        .by = YEAR) -> .resampled.trip
    }else {
      .condensed.trip %>%
      tidytable::summarise(TRIP_JOIN = generic_sample_change_trip_N(flex.vec = TRIP_JOIN,
                                                                    new_trip_N = new_trip_N,
                                                                    vec_length = .N),
                           .by = YEAR) -> .resampled.trip
    }

  return(.resampled.trip)

}
