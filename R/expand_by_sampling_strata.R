#' Expand by observer sampling strata for EBS Pcod
#'
#' @description
#' expands the length frequency data considering observer sampling strata. The length samples are weighted proportional to the number of fish caught in each stratum.
#'
#' @param freq_data length or age frequency input data frame
#'
#' @return length frequency data table with modified WEIGHT1 column incorporating sampling strata weighting
#'
#' @export
#'
expand_by_sampling_strata_EBS_Pcod = function(freq_data) {
  freq_data %>%
    tidytable::summarise(YAGMH_SNUM, .by = c(YEAR, SAMPLING_STRATA_NAME, HAUL_JOIN)) %>% # this should only be used for the bootstrapped samples because the og samples are not expanded by strata.
    tidytable::distinct() %>%
    tidytable::mutate(YS_TNUM = base::sum(YAGMH_SNUM), .by = c(YEAR, SAMPLING_STRATA_NAME)) %>%
    tidytable::summarise(YS_TNUM, .by = c(YEAR, SAMPLING_STRATA_NAME)) %>%
    tidytable::distinct() %>%
    tidytable::mutate(WEIGHT_YS = YS_TNUM/base::sum(YS_TNUM), .by = YEAR) %>%
    tidytable::right_join(freq_data) %>%
    tidytable::mutate(WEIGHT1 = WEIGHT1*WEIGHT_YS)
}

#' Expand by observer sampling strata for generic data download
#'
#' @description
<<<<<<< HEAD
#' expands the length frequency data considering observer sampling strata. The length samples are weighted proportional to the number of fish caught in each stratum. Uses EXTRAPOLATED_NUMBER instead of YAGMH_SNUM.
=======
#' expands the length frequency data considering observer sampling strata. The length samples are weighted proportional to the number of fish caught in each stratum.
>>>>>>> 6bcc9da747d83e7a3e6770b4dd7549175a0c04de
#'
#' @param freq_data length or age frequency input data frame
#'
#' @return length frequency data table with modified WEIGHT1 column incorporating sampling strata weighting
#'
#' @export
#'
expand_by_sampling_strata_generic = function(freq_data) {
  freq_data %>%
    tidytable::summarise(EXTRAPOLATED_NUMBER, .by = c(YEAR, SAMPLING_STRATA_NAME, HAUL_JOIN)) %>% # this should only be used for the bootstrapped samples because the og samples are not expanded by strata.
    tidytable::distinct() %>%
    tidytable::mutate(YS_TNUM = base::sum(EXTRAPOLATED_NUMBER), .by = c(YEAR, SAMPLING_STRATA_NAME)) %>%
    tidytable::summarise(YS_TNUM, .by = c(YEAR, SAMPLING_STRATA_NAME)) %>%
    tidytable::distinct() %>%
    tidytable::mutate(WEIGHT_YS = YS_TNUM/base::sum(YS_TNUM), .by = YEAR) %>%
    tidytable::right_join(freq_data) %>%
    tidytable::mutate(WEIGHT1 = WEIGHT1*WEIGHT_YS)
}
