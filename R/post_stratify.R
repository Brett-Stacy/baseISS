#' Stratify ISS results by post-stratum.
#'
#' @param lfreq_data length frequency input dataframe, not necessarily a data.table or tidytable object yet, hence a different name than subsequent functions (length_DT)
#'
#' @return Dataframe of input sample size by year
#'
#' @export
#'
post_stratify = function(lfreq_data) {

  # get original population proportions-at-length values ----
  og_length_props = fishery_length_props(lfreq_data = lfreq_data,
                                         yrs = yrs,
                                         boot.trip = FALSE, # overrides any global environment assignment
                                         boot.haul = FALSE, # overrides any global environment assignment
                                         boot.length = FALSE, # overrides any global environment assignment
                                         expand.by.sampling.strata = FALSE, # overrides any global environment assignment
                                         expand_using_weighting_factors = expand_using_weighting_factors)
  og_length_props$length %>% # put in the same format as sim_length_props below to be able to join them in rss
    tidytable::rename(og_FREQ = FREQ) -> .og_length_props # rename with og_ prefix to distinguish from sim data when joining later.


  # run resampling iterations ----
  rr <- purrr::map(1:iters, ~fishery_length_props(lfreq_data = lfreq_data,
                                                  yrs = yrs,
                                                  boot.trip = boot.trip, # set to the global environmental assignment
                                                  boot.haul = boot.haul, # set to the global environmental assignment
                                                  boot.length = boot.length, # set to the global environmental assignment
                                                  expand.by.sampling.strata = expand.by.sampling.strata, # set to the global environmental assignment
                                                  expand_using_weighting_factors = expand_using_weighting_factors))

  base::do.call(mapply, c(base::list, rr, SIMPLIFY = FALSE))$length %>% # reverse iterations[[type]] to type[[iterations]], i.e., to length[[1]]
    tidytable::map_df(~base::as.data.frame(.x), .id = "sim") %>% # over all iterations (list elements), map the data frame function to reduce the list to one combined data frame, creating a new column, .id = "sim". tidytable::map_df forces a tidytable class to result. The return is one long table of length = years x iterations x #lengthbins
    tidytable::rename(sim_FREQ = FREQ) -> .sim_length_props


  # compute statistics ----
  ## skip intermediaries ----
  lfreq_data -> .lfreq_data

  ## now get statistics ----
  compute_stats(.sim_length_props, .og_length_props, .lfreq_data)
}



