#' Plus group for length data
#'
#' @description
#' Creates a plus group
#'
#'
#' @param length_DT length frequency input data frame.
#' @param plus_len If set at a value, computes length expansion with a plus-length group (default = FALSE)
#'
#' @return Data frame of length adapted with plus group
#'
#' @export
#'
plus_length = function(length_DT,
                       plus_len = NULL){
  # set lengths > plus-length group to plus-length
  # note: if custom length bins are used the plus length group will already be populated
    length_DT %>%
      tidytable::mutate(LENGTH = tidytable::case_when(LENGTH >= plus_len ~ plus_len,
                                                  LENGTH < plus_len ~ LENGTH)) -> length_DT

  return(length_DT)
}


