#' Bin the length data
#'
#' @description
#' Bin the length data in user-defined vector
#'
#'
#' @param length_DT length frequency input data frame.
#' @param bin bin size (default = 1 cm), also can use custom length bins through defining vector of upper length bin limits, i.e., c(5, 10, 20, 35, 60), plus length group will automatically be populated and denoted with the largest defined bin + 1 (i.e., 61 for provided example)
#'
#' @return Data frame of length adapted to length bin vector
#'
#' @export
#'
bin_length <- function(length_DT,
                       bin = NULL){
  # bin length data
  # bin by cm blocks
  if(length(bin) == 1){
    length_DT %>%
      tidytable::mutate(LENGTH = bin * ceiling(LENGTH / bin)) -> length_DT
  } else{ # custom length bins
    # set up bin bounds
    c(0, bin) %>%
      tidytable::bind_cols(c(bin, bin[length(bin)] + 1)) %>%
      tidytable::rename(lwr = '...1', upr = '...2') -> bin_bnds
    # determine which bin length is in, and define new length as upper bin
    # note, plus bin is denoted as max length bin + 1
    length_DT %>%
      tidytable::distinct(LENGTH) %>%
      tidytable::mutate(new_length = bin_bnds$upr[max(which(bin_bnds$lwr < LENGTH))],
                        .by = c(LENGTH)) -> new_lengths
    # replace lengths in length frequency data with new binned lengths
    length_DT %>%
      tidytable::left_join(new_lengths) %>%
      tidytable::select(-LENGTH, LENGTH = new_length) -> length_DT # inefficiency? does new_length remain in the data frame even though it's no longer needed?
  }

  return(length_DT)
}



