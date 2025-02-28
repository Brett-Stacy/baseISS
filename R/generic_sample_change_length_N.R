#' Resample with replacement a vector of user-defined length. More generic than simply using base::sample
#'
#' @description
#' Modified generic_sample() function to allow more flexibility based on user-defined options for adjusting haul-level sample size.
#'
#' @param flex.vec flexible (can be length 1) vector of input elements
#' @param new_length_N user-defined sample size adjustment options defined in fishery_iss()
#'
#' @return vector of resampled elements
#'
#' @export
#'
generic_sample_change_length_N = function(flex.vec,
                                          new_length_N = NULL)
  {

  # value
  if(new_length_N$type=="value" & new_length_N$replace==TRUE){
    if(is.null(new_length_N$bound)){
      flex.vec[base::sample.int(length(flex.vec),
                                size = new_length_N$amount,
                                replace = TRUE)] -> .new_sample
    }else if(new_length_N=="minimum"){
      flex.vec[base::sample.int(length(flex.vec),
                                size = min(length(flex.vec), new_length_N$amount),
                                replace = TRUE)] -> .new_sample
    }else if(new_length_N=="maximum"){
      flex.vec[base::sample.int(length(flex.vec),
                                size = max(length(flex.vec), new_length_N$amount),
                                replace = TRUE)] -> .new_sample
    }

  }else if(new_length_N$type=="value" & new_length_N$replace==FALSE){
    if(is.null(new_length_N$bound)){
      flex.vec[base::sample.int(length(flex.vec),
                                size = new_length_N$amount,
                                replace = FALSE)] -> .new_sample
    }else if(new_length_N=="minimum"){
      flex.vec[base::sample.int(length(flex.vec),
                                size = min(length(flex.vec), new_length_N$amount),
                                replace = FALSE)] -> .new_sample
    }else if(new_length_N=="maximum"){
      flex.vec[base::sample.int(length(flex.vec),
                                size = max(length(flex.vec), new_length_N$amount),
                                replace = FALSE)] -> .new_sample
    }
  }



  # value
  # ## OLD
  # if(new_length_N$type=="value"){
  #   flex.vec[base::sample.int(length(flex.vec),
  #                             size = ifelse(is.null(new_length_N$bound), new_length_N$amount,
  #                                           ifelse(new_length_N$bound=="minimum", min(length(flex.vec), new_length_N$amount),
  #                                                  max(length(flex.vec), new_length_N$amount))),
  #                             replace = TRUE)] -> .new_sample
  # }

  # proportion
  if(new_length_N$type=="proportion"){
    stop("Under development. Proportion of what? annual median sample size? median sample size over the yrs? how would I calculate that in this function? I would have to calculate it higher up with the length_DT object. also, should there be an option for median or mean? and how should I round? to the whole number?")
  }

  return(.new_sample)

  }




