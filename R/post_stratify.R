#' Post-stratify ISS
#'
#' @description
#' Apply user-requested post-stratification for one or up to two nested post-stratum
#'
#' @param species_code species number code. Used for specific expansion. This is not (yet) an input data filter, it is only for output naming convention and to condition on expansion method.
#' @param area_code area character code. Used for specific expansion. This is not (yet) an input data filter, it is only for output naming convention and to condition on expansion method.
#' @param length_based Boolean. If TRUE, then calculate length iss. if FALSE, then calculate age iss.
#' @param iters number of iterations
#' @param freq_data length or age frequency input data frame
#' @param bin bin size (NULL = 1 cm), also can use custom length bins through defining vector of upper length bin limits, i.e., c(5, 10, 20, 35, 60), plus length group will automatically be populated and denoted with the largest defined bin + 1 (i.e., 61 for provided example)
#' @param plus_len If set at a value, computes length expansion with a plus-length group (default = FALSE)
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
#' @return list of input sample size by post-strata and year
#'
#' @export
#'
post_stratify = function(species_code,
                         area_code,
                         length_based = TRUE,
                         iters = 1,
                         freq_data,
                         bin = NULL,
                         plus_len = NULL,
                         post_strata = NULL,
                         minimum_sample_size = NULL,
                         new_length_N = NULL,
                         max_length,
                         boot.trip = FALSE,
                         boot.haul = FALSE,
                         boot.length = TRUE,
                         boot.age = FALSE,
                         expand.by.sampling.strata = FALSE,
                         expansion_factors = NULL){

  if(base::length(post_strata$strata)==2 & base::isTRUE(post_strata$nested)){ # if there is more than one strata and nesting is desired


    base::print("Two nested post-strata")

    # make an empty list object with nesting strata names, such as ...$GEAR$TRW$AREA2$510
    freq_data %>%
      tidytable::distinct(post_strata$strata %>%
                            tidytable::all_of()) -> .temp

    .temp %>%
      tidytable::distinct(1 %>%
                            tidytable::any_of()) -> .temp1.5

    base::vector("list", .temp1.5[, .N]) -> .temp2
    base::names(.temp2) = tidytable::pull(.temp1.5)
    out_stats = base::list(.temp2)
    base::names(out_stats) = post_strata$strata[1]

    for(j in 1:base::length(.temp2)){
      .temp %>%
        tidytable::filter(!!tidytable::sym(base::names(out_stats))==base::names(.temp2[j])) %>%
        tidytable::select(2) %>%
        base::as.list() %>%
        base::lapply(base::as.list) -> .temp1.6
      names(.temp1.6[[1]]) = as.character(base::unlist(.temp1.6[[1]]))

      out_stats[[post_strata$strata[1]]][[j]] = .temp1.6
    }


    # I know, loops are inefficient, but I'm not sure how else to do this and it only loops a few times (number of stratum levels)
    for(i in 1:base::length(out_stats[[post_strata$strata[1]]])) {
      for(k in 1:base::length(out_stats[[post_strata$strata[1]]][[i]][[1]])){



        freq_data %>%
          tidytable::filter(!!tidytable::sym(post_strata$strata[1])==names(out_stats[[post_strata$strata[1]]])[i],
                            !!tidytable::sym(post_strata$strata[2])==names(out_stats[[1]][[names(out_stats[[post_strata$strata[1]]])[i]]][[1]][k])) -> .freq_data_strata

        # perform the ISS routine. Put all the original code below that did this without post-strata into a function called post_stratify().
        out_stats[[post_strata$strata[1]]][[i]][[1]][[k]] = administrate_iss(species_code = species_code,
                                                                             area_code = area_code,
                                                                             length_based = length_based,
                                                                             iters = iters,
                                                                             freq_data = .freq_data_strata,
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
    }
  }else if(base::length(post_strata$strata)==2 & base::isFALSE(post_strata$nested)){ # more than one strata but nesting is not desired


    base::stop("Feature not developed. Run fishery_iss with multiple unnested post-trata separately instead.")


  }else if(base::length(post_strata$strata)>2){ # more than two nested strata


    base::stop("Greater than two nested post-strata not developed.")


  }else if(base::length(post_strata$strata)==1 & base::isTRUE(post_strata$nested)){ # one strata but nesting is requested (not possible)


    base::stop("Nesting not possible with only one post-strata")


  }else{# only one strata (nesting is not possible)


    base::print("one post-strata")


    # make an empty list object named the post_strata name where each list element is a distinct strata level. this is a clunky process but I could not think of a better way to code it.
    freq_data %>%
      tidytable::distinct(post_strata$strata %>%
                            tidytable::all_of()) -> .temp

    base::vector("list", .temp[, .N]) -> .temp2
    base::names(.temp2) = tidytable::pull(.temp)
    out_stats = base::list(.temp2)
    base::names(out_stats) = post_strata$strata

    # I know, loops are inefficient, but I'm not sure how else to do this and it only loops a few times (number of stratum levels)
    for(i in 1:base::length(out_stats[[post_strata$strata]])) {
      freq_data %>%
        tidytable::filter(!!tidytable::sym(post_strata$strata) == names(out_stats[[post_strata$strata]])[i]) -> .freq_data_strata

      # perform the ISS routine. Put all the original code below that did this without post-strata into a function called post_stratify().
      out_stats[[post_strata$strata]][[i]] = administrate_iss(species_code = species_code,
                                                              area_code = area_code,
                                                              length_based = length_based,
                                                              iters = iters,
                                                              freq_data = .freq_data_strata,
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
  }
  return(out_stats)
}

