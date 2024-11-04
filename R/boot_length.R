#' Resample length frequency data w/replacement.
#'
#' @param length_DT length frequency input data frame. Can be the output object from boot_trip() if boot.trip == true, or boot_haul() if boot.haul == true, or both
#' @param new_length_N see description from fishery_iss.R. MAY DEPRECATE IF DON'T SUBSAMPLE INSIDE THIS UNCTION.
#'
#' @return length frequency data table including resampled length frequencies as LENGTH and associated data
#'
#' @export
#'
boot_length = function(length_DT,
                       new_length_N = NULL) {
  length_DT %>%

    tidytable::mutate(LENGTH = generic_sample(LENGTH, n.samples = .N), .by = c(YEAR, HAUL_JOIN)) %>%
    # tidytable::mutate(LENGTH = ifelse(base::is.null(new_length_N), generic_sample(LENGTH, n.samples = .N), generic_sample_change_length_N(LENGTH, new_length_N)), .by = c(YEAR, HAUL_JOIN)) %>%
    # tidytable::mutate(LENGTH = generic_sample(LENGTH, n.samples = ifelse(base::is.null(new_length_N), .N, min(.N, new_length_N$amount))), .by = c(YEAR, HAUL_JOIN)) %>%
    tidytable::summarise(SUM_FREQUENCY = n(base::unique(LENGTH)), .by = c(YEAR, HAUL_JOIN, LENGTH)) %>% # after this line is where I would incorporate a different sample size feature. would need to set YAGMH_SFREQ to requested sample size.
    tidytable::mutate(YAGMH_SFREQ = base::sum(SUM_FREQUENCY), .by = c(YEAR, HAUL_JOIN)) %>%
    tidytable::left_join(length_DT %>%
                           tidytable::distinct(YEAR, HAUL_JOIN, .keep_all = TRUE) %>%
                           tidytable::select(-tidytable::any_of(c("LENGTH", "YAGMH_SFREQ"))))
}
# for testing
# length_DT = .freq
# tidytable::mutate(length_DT, LENGTH = generic_sample_change_length_N(LENGTH, new_length_N), .by = c(YEAR, HAUL_JOIN))









