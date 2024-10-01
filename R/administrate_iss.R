#' Administrate ISS
#'
#' @param species_code species number code. Used for specific expansion. This is not (yet) an input data filter, it is only for output naming convention and to condition on expansion method.
#' @param area_code area character code. Used for specific expansion. This is not (yet) an input data filter, it is only for output naming convention and to condition on expansion method.
#' @param length_based Boolean. If TRUE, then calculate length iss. if FALSE, then calculate age iss.
#' @param iters number of iterations
#' @param freq_data length or age frequency input data frame
#'
#' @return Data frame of input sample size by year
#'
#' @export
#'
administrate_iss = function(species_code,
                            area_code,
                            length_based = TRUE,
                            iters = 1,
                            freq_data) {

  ######## NEW (with age)
  # get original population proportions-at-length or -age values ----
  og_props = fishery_props(species_code = species_code,
                           area_code = area_code,
                           length_based = length_based,
                           freq_data = freq_data,
                           yrs = yrs,
                           boot.trip = FALSE, # overrides any global environment assignment
                           boot.haul = FALSE, # overrides any global environment assignment
                           boot.length = FALSE, # overrides any global environment assignment
                           boot.age = FALSE,
                           expand.by.sampling.strata = FALSE, # overrides any global environment assignment
                           expansion_factors = expansion_factors)


  # create a useful name based on length or age
  base::ifelse(base::isTRUE(length_based), "length", "age") -> .data_type


  og_props[[.data_type]] %>% # put in the same format as sim_props below to be able to join them in rss
    tidytable::rename(og_FREQ = FREQ) -> .og_props # rename with og_ prefix to distinguish from sim data when joining later.


  # run resampling iterations ----
  rr <- purrr::map(1:iters, ~fishery_props(species_code = species_code,
                                           area_code = area_code,
                                           length_based = length_based,
                                           freq_data = freq_data,
                                           yrs = yrs,
                                           boot.trip = boot.trip, # set to the global environmental assignment
                                           boot.haul = boot.haul, # set to the global environmental assignment
                                           boot.length = boot.length, # set to the global environmental assignment
                                           boot.age = boot.age,
                                           expand.by.sampling.strata = expand.by.sampling.strata, # set to the global environmental assignment
                                           expansion_factors = expansion_factors))


  base::do.call(mapply, c(base::list, rr, SIMPLIFY = FALSE))[[.data_type]] %>% # reverse iterations[[type]] to type[[iterations]], i.e., to length[[1]]
    tidytable::map_df(~base::as.data.frame(.x), .id = "sim") %>% # over all iterations (list elements), map the data frame function to reduce the list to one combined data frame, creating a new column, .id = "sim". tidytable::map_df forces a tidytable class to result. The return is one long table of length = years x iterations x #lengthbins
    tidytable::rename(sim_FREQ = FREQ) -> .sim_props


  # compute statistics ----
  ## skip intermediaries ----
  freq_data -> .freq_data

  ## now get statistics ----
  compute_stats(sim_props = .sim_props,
                og_props = .og_props,
                freq_data = .freq_data,
                iters = iters)


}



