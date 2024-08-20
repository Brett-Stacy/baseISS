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


  if(!is.null(post_strata)){ # post_stratify. PROBS MAKE THIS A FUNCTION: post_stratify.   output will be organized as a list with each entry corresponding to a post_strata name
    if(base::length(post_strata$strata)==2 & base::isTRUE(post_strata$nested)){ # if there is more than one strata and nesting is desired


      base::print("Maximum two strata and nesting is possible")

      # make an empty list object with nesting strata names, such as ...$GEAR$TRW$AREA2$510
      lfreq_data %>%
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



          lfreq_data %>%
            tidytable::filter(!!tidytable::sym(post_strata$strata[1])==names(out_stats[[post_strata$strata[1]]])[i],
                              !!tidytable::sym(post_strata$strata[2])==names(out_stats[[1]][[names(out_stats[[post_strata$strata[1]]])[i]]][[1]][k])) -> .lfreq_data_strata

          # perform the ISS routine. Put all the original code below that did this without post-strata into a function called post_stratify().
          .lfreq_data_strata %>%
            administrate_iss() -> out_stats[[post_strata$strata[1]]][[i]][[1]][[k]]

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
      lfreq_data %>%
        tidytable::distinct(post_strata$strata %>%
                              tidytable::all_of()) -> .temp

      base::vector("list", .temp[, .N]) -> .temp2
      base::names(.temp2) = tidytable::pull(.temp)
      out_stats = base::list(.temp2)
      base::names(out_stats) = post_strata$strata

      # I know, loops are inefficient, but I'm not sure how else to do this and it only loops a few times (number of stratum levels)
      for(i in 1:base::length(out_stats[[post_strata$strata]])) {
        lfreq_data %>%
          tidytable::filter(!!tidytable::sym(post_strata$strata) == names(out_stats[[post_strata$strata]])[i]) -> .lfreq_data_strata

        # perform the ISS routine. Put all the original code below that did this without post-strata into a function called post_stratify().
        .lfreq_data_strata %>%
          administrate_iss() -> out_stats[[post_strata$strata]][[i]]
      }
    }
  }else { # do not post-stratify

    base::print("no post-stratification")

    lfreq_data %>%
      administrate_iss() -> out_stats

  }

  return(out_stats)

}























