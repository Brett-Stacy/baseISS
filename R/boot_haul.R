#' Resample hauls w/replacement, changing the number of hauls if desired
#'
#' @param freq_data length or age frequency input data frame. Can be the output object from boot_trip() if boot.trip == true
#' @param new_haul_N user-defined sample size adjustment options defined in fishery_iss()
#'
#' @return frequency data table including resampled hauls as HAUL_JOIN and associated data
#'
#' @export
#'
boot_haul = function(freq_data,  # based on surveyISS::boot_haul
                     new_haul_N = NULL)
{

  freq_data %>%
    tidytable::select(YEAR, TRIP_JOIN, HAUL_JOIN) %>%
    tidytable::distinct() -> .condensed.haul
  if(base::is.null(new_haul_N)){
    .condensed.haul %>%
      tidytable::mutate(HAUL_JOIN = generic_sample(HAUL_JOIN,
                                                   n.samples = .N),
                        .by = c(YEAR, TRIP_JOIN)) -> .resampled.haul
  }else {
    .condensed.haul %>%
      tidytable::summarise(HAUL_JOIN = generic_sample_change_haul_N(flex.vec = HAUL_JOIN,
                                                                    new_haul_N = new_haul_N,
                                                                    vec_length = .N),
                           .by = c(YEAR, TRIP_JOIN)) -> .resampled.haul
  }

  return(.resampled.haul)

}
