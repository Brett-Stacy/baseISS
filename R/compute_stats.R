#' Compute fishery ISS statistics
#'
#' @description
#' Wrapper function to compute statistics of bootstrap resampling of length or age composition.
#'
#' @param sim_props list of replicated abundance at length or age
#' @param og_props original abundance at length or age (computed with data that has not been resampled)
#' @param freq_data length or age frequency input data frame
#' @param iters number of iterations
#' @param boot.length Boolean. Resample lengths w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length
#'
#' @return list of dataframes for realized sample size by replicate (.rss for length or age composition),
#' input sample size by year (.iss),
#' bias in resampled comp data compared to original values (.bias for length or age composition)
#'
#' @export
#'
compute_stats <- function(sim_props = NULL,
                          og_props = NULL,
                          freq_data = NULL,
                          iters = 1,
                          boot.length = NULL){



  .rss = rss(sim_props = sim_props,
             og_props = og_props)


  # length or age comps:
  # compute harmonic mean of iterated realized sample size, which is the input sample size (iss)
  .iss <- iss(rss = .rss,
              freq_data = freq_data,
              boot.length = boot.length)

  # compute average relative bias in pop'n estimates (avg relative bias across length)
  .bias <- bias(sim_props = sim_props,
                og_props = og_props)

  # return
  list(iterations = iters,
       og_props = og_props,
       # sim_props = sim_props,
       rss = .rss,
       iss = .iss,
       bias = .bias)



}








