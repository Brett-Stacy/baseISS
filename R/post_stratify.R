#' Post-stratify ISS
#'
#' @description
#' Apply user-requested post-stratification for one or up to two nested post-stratum
#'
#' @param freq_data length frequency input data frame
#' @param post_strata list(strata = character string, nested = Boolean) if NULL, then no post stratification. The first element of post_strata is a character string with name(s) of post strata type. Accepted types are "GEAR", etc. These must be column name(s) in the data frame where each row has an entry and there are no NAs. The second element in post_strata allows for nested post-strata (e.g., "GEAR", "SEX") that are in order of the desired nested hierarchy, then the final results will be a nested list in order of the listed post-strata as well. Perhaps there should be an error message for attempts with strata names that are not in freq_data or it does exist, but there are NAs in it.
#'
#' @return list of input sample size by post-strata and year
#'
#' @export
#'
post_stratify = function(freq_data,
                         post_strata){

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
        .freq_data_strata %>%
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
      .freq_data_strata %>%
        administrate_iss() -> out_stats[[post_strata$strata]][[i]]
    }
  }
  return(out_stats)
}

