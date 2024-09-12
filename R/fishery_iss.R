#' Fishery input sample size function
#'
#' @description
#' Bootstrap data sources to replicate EBS Pcod fishery observer measurements of length or age composition
#' for computation of input sample size.
#' Follows loosely srvy_iss.R from surveyISS package.
#'
#' @param species_code species number code. Used for specific expansion. This is not (yet) an input data filter, it is only for output naming convention and to condition on expansion method.
#' @param area_code area character code. Used for specific expansion. This is not (yet) an input data filter, it is only for output naming convention and to condition on expansion method.
#' @param length_based Boolean. If TRUE, then calculate length iss. if FALSE, then calculate age iss.
#' @param iters number of iterations
#' @param freq_data length or age frequency input data frame
#' @param yrs any year filter >= (default = NULL)
#' @param post_strata list(strata = character string, nested = Boolean) if NULL, then no post stratification. The first element of post_strata is a character string with name(s) of post strata type. Accepted types are "GEAR", etc. These must be column name(s) in the data frame where each row has an entry and there are no NAs. The second element in post_strata allows for nested post-strata (e.g., "GEAR", "SEX") that are in order of the desired nested hierarchy, then the final results will be a nested list in order of the listed post-strata as well. Perhaps there should be an error message for attempts with strata names that are not in freq_data or it does exist, but there are NAs in it.
#' @param minimum_sample_size list(resolution = character string, size = integer) if NULL, then no minimum sample size. The sample size at the chosen resolution (must be column in freq_data, e.g., YAGM_SFREQ for EBS Pcod) for which to filter out data that does not meet the minimum sample size requested. Example: minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30). Note that this filters to keep only samples GREATER than 30 at the YAGM resolution.
#' @param boot.trip Boolean. Resample trips w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length or -age
#' @param boot.haul Boolean. Resample hauls w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length or -age
#' @param boot.length Boolean. Resample lengths w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length
#' @param boot.age Boolean. Resample ages w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-age
#' @param expand.by.sampling.strata expand by observer sampling strata? If TRUE, then an additional weighting factor is calculated and applied to WEIGHT1 based on the number of fish caught in each sampling stratum.
#' @param expand_using_weighting_factors expand using weighting factors? If TRUE, then then "WEIGHT2" and "WEIGHT4" are applied.
#'
#' @return Dataframe of input sample size by year
#'
#' @export
#'
fishery_iss <- function(species_code,
                        area_code,
                        length_based = TRUE,
                        iters = 1,
                        freq_data,
                        yrs = NULL,
                        post_strata = NULL,
                        minimum_sample_size = NULL,
                        boot.trip = FALSE,
                        boot.haul = FALSE,
                        boot.length = TRUE,
                        boot.age = FALSE,
                        expand.by.sampling.strata = FALSE,
                        expand_using_weighting_factors = TRUE) # expanding by weighting factors must be the same for og props and resampled props for an apples to apples comparison
  {


  # Necessary checks
  if(base::isTRUE(boot.length & boot.age)){
    base::stop("Feature not developed. Run fishery_iss with length and age separately instead.")
  }
  if(any(colnames(freq_data) %in% c("SEX", "Sex", "sex")) & isFALSE(!any(post_strata$strata %in% c("SEX", "Sex", "sex")))){
    base::stop("Sex cannot yet be a column name in freq_data if it is not being post-stratified by. This arose because of my method for implementing WEIGHT1 in fishery_props.R to accomodate age data. This should be addressed in the future, but note that this is the only column other than length that will impact weight1 calculation since all other columns will be the same for each age observation.")
  }


  # Post-stratify if requested
  if(!is.null(post_strata)){ # post_stratify. output will be organized as a list with each entry corresponding to a post_strata name

    freq_data %>%
      post_stratify(post_strata = post_strata) -> out_stats

  }else { # do not post-stratify

    base::print("no post-stratification")

    freq_data %>%
      administrate_iss() -> out_stats

  }

  # Label the output list object as length or age to inexorably tie the data type to the output
  base::ifelse(base::isTRUE(length_based), "length", "age") -> .data_type

  out_stats = list(out_stats)
  names(out_stats) = .data_type


  return(out_stats)

}























