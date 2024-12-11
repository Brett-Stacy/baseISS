#' Resample hauls w/replacement as a vector of user-defined length
#'
#' @description
#' Modified generic_sample() function to allow more flexibility based on user-defined options for adjusting number of hauls as a proportion
#'
#' @param flex.vec flexible (can be length 1) vector of input elements
#' @param new_haul_N user-defined sample size adjustment options defined in fishery_iss()
#' @param vec_length pass the useful .N to this function as vec_length
#'
#' @return vector of resampled elements
#'
#' @export
#'
generic_sample_change_haul_N = function(flex.vec,
                                        new_haul_N = NULL,
                                        vec_length = NULL)
{


  # proportion
  if(new_haul_N$type=="proportion"){
    flex.vec[base::sample.int(length(flex.vec),
                              size = round(new_haul_N$amount*vec_length),
                              replace = TRUE)] -> .new_sample
  }

  # value
  if(new_haul_N$type=="value"){
    stop("not developed")
  }


  return(.new_sample)

}
