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
#' @param bin bin size (NULL = 1 cm), also can use custom length bins through defining vector of upper length bin limits, i.e., c(5, 10, 20, 35, 60), plus length group will automatically be populated and denoted with the largest defined bin + 1 (i.e., 61 for provided example)
#' @param plus_len If set at a value other than NULL, computes length expansion with a plus-length group (default = FALSE)
#' @param post_strata list(strata = character string, nested = Boolean) if NULL, then no post stratification. The first element of post_strata is a character string with name(s) of post strata type. Accepted types are "GEAR", etc. These must be column name(s) in the data frame where each row has an entry and there are no NAs. The second element in post_strata allows for nested post-strata (e.g., "GEAR", "SEX") that are in order of the desired nested hierarchy, then the final results will be a nested list in order of the listed post-strata as well. Perhaps there should be an error message for attempts with strata names that are not in freq_data or it does exist, but there are NAs in it.
#' @param minimum_sample_size list(resolution = character string, size = integer). If NULL, then no minimum sample size. If not NULL, The sample size at the chosen resolution (must be column in freq_data, e.g., YAGM_SFREQ for EBS Pcod) for which to filter out data that does not meet the minimum sample size requested. Example: minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30). Note that this filters to keep only samples GREATER than 30 at the YAGM resolution.
#' @param new_length_N list(type = character ("value", or "proportion"), bound = NULL or character ("minimum", or "maximum") amount = numeric). If NULL, then the number of length samples resampled in a haul equals the number actually sampled. If not NULL, then the haul-level number of samples is changed by type (acceptable entries are "fixed", or "proportion") at an amount (acceptable entries are an integer number or proportion). The amount can be less than or greater than the true N. Note that if it is either less than or greater than, the minimum of the two is chosen for N (this is still under consideration and may change in the future). The true N is taken to be... DOES THIS ONLY MATTER IF WE NEED A THRESHOLD TO DECIDE WHEN TO TAKE THE MAX?? The samples are still drawn with replacement. Warning: cannot do this if post_strata = "SEX"
#' @param max_length integer or "data_derived" (default). Provides the maximum length bin to record proportions-at-length. Integer values must be equal to or greater than the maximum length observed in the data (this will be changed once a plus-group option is coded in the future). "data_derived" forces the maximum length to be calculated from the data.
#' @param boot.trip Boolean. Resample trips w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length or -age
#' @param boot.haul Boolean. Resample hauls w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length or -age
#' @param boot.length Boolean. Resample lengths w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length
#' @param boot.age Boolean. Resample ages w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-age
#' @param expand.by.sampling.strata expand by observer sampling strata? If TRUE, then an additional weighting factor is calculated and applied to WEIGHT1 based on the number of fish caught in each sampling stratum.
#' @param expansion_factors expansion weighting factors to apply to the proportions. If NULL, then no expansion factors are applied. Otherwise, the conditional options coded in expand_props.R are "haul_numbers" or "haul_numbers" and "month_numbers". Consider improving/generalizing this by calling it expansion_weighting_factors = list(type = c("weight", "number"), factors = c("haul", "area", "month", "gear", etc.) to give the user the option of what aspects (columns) of the data to expand by and do it by weight of fish or number of fish in those categories.
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
                        bin = NULL,
                        plus_len = NULL,
                        post_strata = NULL,
                        minimum_sample_size = NULL,
                        new_length_N = NULL,
                        max_length = "data_derived",
                        boot.trip = FALSE,
                        boot.haul = FALSE,
                        boot.length = TRUE,
                        boot.age = FALSE,
                        expand.by.sampling.strata = FALSE,
                        expansion_factors = NULL)
  {


  ### Necessary checks
  if(base::isTRUE(boot.length & boot.age)){
    base::stop("Feature not developed. Run fishery_iss with length and age separately instead.")
  }
  if(any(colnames(freq_data) %in% c("SEX", "Sex", "sex")) & isFALSE(any(post_strata$strata %in% c("SEX", "Sex", "sex")))){
    base::stop("Sex cannot yet be a column name in freq_data if it is not being post-stratified by. This arose because of my method for implementing WEIGHT1 in fishery_props.R to accomodate age data. This is also impacted when applying tidytable::distinct in boot_length() because WEIGHT1 is different between sexes. This should be addressed in the future, but note that this is the only column other than length that will impact weight1 calculation since all other columns will be the same for each age observation.")
  }
  if(!is.null(post_strata)){
    if(any(post_strata$strata %in% c("SEX", "Sex", "sex")) & !is.null(new_length_N)){
      base::stop("Sex cannot yet be a post-stratification at the same time as alternative length N values are resampled. This is because males and females are likely sampled at different rates and the new_length_N would need to be sex specific.")
    }
  }


  ### Necessary preliminaries
  # globals ----
  # year switch
  if (is.null(yrs)) yrs <- 0 # when NULL, drop yrs to 0 so it picks up all possible years

  # prep data ----
  freq_data %>%
      tidytable::filter(YEAR >= yrs) -> freq_data # filters for only years requested and forces freq_data into a tidytable format

  # bin ----


  # uncount the data frame if it is compressed by count of length or age, i.e., flatten the data frame. This only impacts length-only data frames because age input data frames should always be flattened. This avoids uncounting it in every resampling iteration. Work with the SUM_FREQUENCY column name for now, may need to change this with alternative input data frames.
  if("SUM_FREQUENCY" %in% base::names(freq_data)){ # for EBS Pcod data curated with pre-processing steps by Steve B.
    freq_data %>%
      tidytable::uncount(SUM_FREQUENCY) -> freq_data
  }else if("FREQUENCY" %in% base::names(freq_data)){ # for generic data download
    freq_data %>%
      tidytable::uncount(FREQUENCY) -> freq_data
  }



  ### Post-stratify if requested
  if(!is.null(post_strata)){ # post_stratify. output will be organized as a list with each entry corresponding to a post_strata name

    out_stats = post_stratify(species_code = species_code,
                              area_code = area_code,
                              length_based = length_based,
                              iters = iters,
                              freq_data = freq_data,
                              bin = bin,
                              plus_len = plus_len,
                              post_strata = post_strata,
                              minimum_sample_size = minimum_sample_size,
                              new_length_N = new_length_N,
                              max_length = max_length,
                              boot.trip = boot.trip,
                              boot.haul = boot.haul,
                              boot.length = boot.length,
                              boot.age = boot.age,
                              expand.by.sampling.strata = expand.by.sampling.strata,
                              expansion_factors = expansion_factors)

  }else { # do not post-stratify

    base::print("no post-stratification")

    out_stats = administrate_iss(species_code = species_code,
                                 area_code = area_code,
                                 length_based = length_based,
                                 iters = iters,
                                 freq_data = freq_data,
                                 bin = bin,
                                 plus_len = plus_len,
                                 minimum_sample_size = minimum_sample_size,
                                 new_length_N = new_length_N,
                                 max_length = max_length,
                                 boot.trip = boot.trip,
                                 boot.haul = boot.haul,
                                 boot.length = boot.length,
                                 boot.age = boot.age,
                                 expand.by.sampling.strata = expand.by.sampling.strata,
                                 expansion_factors = expansion_factors)

  }

  ###Label the output list object as length or age to inexorably tie the data type to the output
  base::ifelse(base::isTRUE(length_based), "length", "age") -> .data_type
  out_stats = list(out_stats)
  names(out_stats) = .data_type

  ### Include the function arguments in the output as a default
  out_stats$arguments = match.call()



  return(out_stats)

}























