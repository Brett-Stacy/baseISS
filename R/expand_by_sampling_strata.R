#' Expand by observer sampling strata
#'
#' @description
#' expands the length frequency data considering observer sampling strata. The length samples are weighted proportional to the number of fish caught in each stratum.
#'
#' @param length_DT length frequency input data table.
#'
#' @return length frequency data table with modified WEIGHT1 column incorporating sampling strata weighting
#'
#' @export
#'
expand_by_sampling_strata = function(length_DT) {
  length_DT %>%
    tidytable::summarise(YAGMH_SNUM, .by = c(YEAR, SAMPLING_STRATA_NAME, HAUL_JOIN)) %>% # this should only be used for the bootstrapped samples because the og samples are not expanded by strata.
    tidytable::distinct() %>%
    tidytable::mutate(YS_TNUM = base::sum(YAGMH_SNUM), .by = c(YEAR, SAMPLING_STRATA_NAME)) %>%
    tidytable::summarise(YS_TNUM, .by = c(YEAR, SAMPLING_STRATA_NAME)) %>%
    tidytable::distinct() %>%
    tidytable::mutate(WEIGHT_YS = YS_TNUM/base::sum(YS_TNUM), .by = YEAR) %>%
    tidytable::right_join(length_DT) %>%
    tidytable::mutate(WEIGHT1 = WEIGHT1*WEIGHT_YS)
}
