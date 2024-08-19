#' Fishery input sample size function
#'
#' @description
#' Bootstrap data sources to replicate EBS Pcod fishery observer measurements of length composition
#' for computation of input sample size.
#' Follows loosely srvy_iss.R from surveyISS package.
#'
#' @param iters number of iterations
#' @param lfreq_data  length frequency input dataframe
#' @param yrs any year filter >= (default = NULL)
#' @param post_strata if NULL, then no post stratification. Otherwise, character string with name(s) of post strata type. Accepted types are "GEAR", etc. This must be a column name in the data frame where each row has an entry and there are no NAs; perhaps there should be an error message for attempts with strata names that are not in lfreq_data or it does exist, but there are NAs in it. This needs to be developed to accept only a list(strata = c(), nested = FALSE) to allow for nested post-strata (e.g., "GEAR", "SEX") that are ordered in the desired hierarchy, then the final results will be a nested list in order of the listed post-strata
#' @param boot.trip Boolean. Resample trips w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length
#' @param boot.haul Boolean. Resample hauls w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length
#' @param boot.length Boolean. Resample lengths w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length
#' @param expand.by.sampling.strata expand by observer sampling strata? If TRUE, then an additional weighting factor is calculated and applied to WEIGHT1 based on the number of fish caught in each sampling stratum.
#' @param expand_using_weighting_factors expand using weighting factors? If TRUE, then then "WEIGHT2" and "WEIGHT4" are applied.
#'
#' @return Dataframe of input sample size by year
#'
#' @export
#'
fishery_iss <- function(iters = 1,
                        lfreq_data,
                        yrs = NULL,
                        post_strata = NULL,
                        boot.trip = FALSE,
                        boot.haul = FALSE,
                        boot.length = FALSE,
                        expand.by.sampling.strata = FALSE,
                        expand_using_weighting_factors = TRUE) # expanding by weighting factors must be the same for og props and resampled props for an apples to apples comparison
  {


  if(!is.null(post_strata)){ # post_strata switch. output will be organized as a list with each entry corresponding to a post_strata name

    # make a list object named the post_strata name where each list element is a distinct strata level
    lfreq_data %>%
      tidytable::distinct(post_strata %>%
                            tidytable::all_of()) -> .temp
    # this is a clunky process but I could not think of a better way to code it.
    base::vector("list", .temp[, .N]) -> .temp2
    base::names(.temp2) = tidytable::pull(.temp)
    out_stats = base::list(.temp2)
    base::names(out_stats) = post_strata

    # I know, loops are inefficient, but I'm not sure how else to do this and it only loops a few times (number of stratum levels)
    for(i in 1:base::length(out_stats[[post_strata]])) {
      lfreq_data %>%
        tidytable::filter(!!sym(post_strata) == names(out_stats[[post_strata]])[i]) -> lfreq_data_strata

      # perform the ISS routine. Put all the original code below that did this without post-strata into a function called post_stratify().
      lfreq_data_strata %>%
        post_stratify() -> out_stats[[post_strata]][[i]]

    }


  }else {


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
    out_stats <- compute_stats(.sim_length_props, .og_length_props, .lfreq_data)
  }



  return(out_stats)

}























