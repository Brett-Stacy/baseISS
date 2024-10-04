#' Administrate ISS
#'
#' @param species_code species number code. Used for specific expansion. This is not (yet) an input data filter, it is only for output naming convention and to condition on expansion method.
#' @param area_code area character code. Used for specific expansion. This is not (yet) an input data filter, it is only for output naming convention and to condition on expansion method.
#' @param length_based Boolean. If TRUE, then calculate length iss. if FALSE, then calculate age iss.
#' @param iters number of iterations
#' @param freq_data length or age frequency input data frame
#' @param minimum_sample_size list(resolution = character string, size = integer). If NULL, then no minimum sample size. If not NULL, The sample size at the chosen resolution (must be column in freq_data, e.g., YAGM_SFREQ for EBS Pcod) for which to filter out data that does not meet the minimum sample size requested. Example: minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30). Note that this filters to keep only samples GREATER than 30 at the YAGM resolution.
#' @param new_length_N list(type = character ("value", or "proportion"), bound = NULL or character ("minimum", or "maximum") amount = numeric). If NULL, then the number of length samples resampled in a haul equals the number actually sampled. If not NULL, then the haul-level number of samples is changed by type (acceptable entries are "fixed", or "proportion") at an amount (acceptable entries are an integer number or proportion). The amount can be less than or greater than the true N. Note that if it is either less than or greater than, the minimum of the two is chosen for N (this is still under consideration and may change in the future). The true N is taken to be... DOES THIS ONLY MATTER IF WE NEED A THRESHOLD TO DECIDE WHEN TO TAKE THE MAX?? The samples are still drawn with replacement. Warning: cannot do this if post_strata = "SEX"
#' @param boot.trip Boolean. Resample trips w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length or -age
#' @param boot.haul Boolean. Resample hauls w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length or -age
#' @param boot.length Boolean. Resample lengths w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length
#' @param boot.age Boolean. Resample ages w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-age
#' @param expand.by.sampling.strata expand by observer sampling strata? If TRUE, then an additional weighting factor is calculated and applied to WEIGHT1 based on the number of fish caught in each sampling stratum.
#' @param expansion_factors expansion weighting factors to apply to the proportions. If NULL, then no expansion factors are applied. Otherwise, the conditional options coded in expand_props.R are "haul_numbers" or "haul_numbers" and "month_numbers". Consider improving/generalizing this by calling it expansion_weighting_factors = list(type = c("weight", "number"), factors = c("haul", "area", "month", "gear", etc.) to give the user the option of what aspects (columns) of the data to expand by and do it by weight of fish or number of fish in those categories.
#'
#' @return Data frame of input sample size by year
#'
#' @export
#'
administrate_iss = function(species_code,
                            area_code,
                            length_based = TRUE,
                            iters = 1,
                            freq_data,
                            minimum_sample_size = NULL,
                            new_length_N = NULL,
                            boot.trip = FALSE,
                            boot.haul = FALSE,
                            boot.length = TRUE,
                            boot.age = FALSE,
                            expand.by.sampling.strata = FALSE,
                            expansion_factors = NULL) {

  ######## NEW (with age)
  # get original population proportions-at-length or -age values ----
  og_props = fishery_props(species_code = species_code,
                           area_code = area_code,
                           length_based = length_based,
                           freq_data = freq_data,
                           minimum_sample_size = minimum_sample_size,
                           new_length_N = NULL,
                           boot.trip = FALSE,
                           boot.haul = FALSE,
                           boot.length = FALSE,
                           boot.age = FALSE,
                           expand.by.sampling.strata = FALSE,
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
                                           minimum_sample_size = minimum_sample_size,
                                           new_length_N = new_length_N,
                                           boot.trip = boot.trip,
                                           boot.haul = boot.haul,
                                           boot.length = boot.length,
                                           boot.age = boot.age,
                                           expand.by.sampling.strata = expand.by.sampling.strata,
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
                iters = iters,
                boot.length = boot.length)


}



