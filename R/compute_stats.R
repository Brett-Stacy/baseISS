#' Compute fishery ISS statistics
#'
#' @description
#' Wrapper function to compute statistics of bootstrap resampling of length composition.
#'
#' @param r_length list of replicated abundance at length
#' @param ogl original abundance at length (computed with data that has not been resampled)
#' @param lfreq_data length frequency input dataframe
#'
#' @return list of dataframes for realized sample size by replicate (.rss_length for length composition),
#' input sample size BY YEAR? (.iss_length for length composition),
#' bias in resampled comp data compared to original values (.bias_length for length composition)
#'
#' @export
#'
comp_stats <- function(r_length,
                       ogl,
                       lfreq_data){


  rss_length(r_length, ogl) -> .rss_length


  # length comps:
  # compute harmonic mean of iterated realized sample size, which is the input sample size (iss)
  .iss_length <- iss_length(.rss_length, lfreq_data, survey_region)

  # compute average relative bias in pop'n estimates (avg relative bias across length)
  .bias_length <- bias_length(r_length, ogl)

  # return
  list(rss_length = .rss_length,
       mean_length = .mean_length,
       iss_length = .iss_length,
       bias_length = .bias_length)



}








