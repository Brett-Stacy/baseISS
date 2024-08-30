#' Compute fishery ISS statistics
#'
#' @description
#' Wrapper function to compute statistics of bootstrap resampling of length or age composition.
#'
#' @param sim_props list of replicated abundance at length or age
#' @param og_props original abundance at length or age (computed with data that has not been resampled)
#' @param lfreq_data length or age frequency input dataframe
#'
#' @return list of dataframes for realized sample size by replicate (.rss for length or age composition),
#' input sample size by year (.iss),
#' bias in resampled comp data compared to original values (.bias for length or age composition)
#'
#' @export
#'
compute_stats <- function(sim_props,
                          og_props,
                          freq_data){



  .rss = rss(sim_props = sim_props, og_props = og_props)


  # length comps:
  # compute harmonic mean of iterated realized sample size, which is the input sample size (iss)
  .iss <- iss(.rss, lfreq_data)

  # compute average relative bias in pop'n estimates (avg relative bias across length)
  .bias <- bias(sim_props, og_props)

  # return
  list(iterations = iters,
       og_props = og_props,
       rss = .rss,
       iss = .iss,
       bias = .bias)



}








