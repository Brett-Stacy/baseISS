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
#' @param post_strata list(strata = character string, nested = Boolean) if NULL, then no post stratification. The first element of post_strata is a character string with name(s) of post strata type. Accepted types are "GEAR", etc. These must be column name(s) in the data frame where each row has an entry and there are no NAs. The second element in post_strata allows for nested post-strata (e.g., "GEAR", "SEX") that are in order of the desired nested hierarchy, then the final results will be a nested list in order of the listed post-strata as well. Perhaps there should be an error message for attempts with strata names that are not in lfreq_data or it does exist, but there are NAs in it.
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


  if(!is.null(post_strata)){ # post_stratify. output will be organized as a list with each entry corresponding to a post_strata name

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
        tidytable::filter(!!sym(post_strata) == names(out_stats[[post_strata]])[i]) -> .lfreq_data_strata

      # perform the ISS routine. Put all the original code below that did this without post-strata into a function called post_stratify().
      .lfreq_data_strata %>%
        administrate_iss() -> out_stats[[post_strata]][[i]]

    }


  }else { # do not post-stratify

    lfreq_data %>%
      administrate_iss() -> out_stats

  }



  return(out_stats)

}























