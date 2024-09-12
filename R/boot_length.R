#' Resample length frequency data w/replacement.
#'
#' @param length_DT length frequency input data frame. Can be the output object from boot_trip() if boot.trip == true, or boot_haul() if boot.haul == true, or both
#'
#' @return length frequency data table including resampled length frequencies as LENGTH and associated data
#'
#' @export
#'
boot_length = function(length_DT) {
  length_DT %>%
    # tidytable::uncount(SUM_FREQUENCY) %>%
    tidytable::mutate(LENGTH = generic_sample(LENGTH, n.samples = .N), .by = c(YEAR, HAUL_JOIN)) %>%  # should this include .by trip join?? I don't think so because I think it would give the same answer
    tidytable::summarise(SUM_FREQUENCY = n(base::unique(LENGTH)), .by = c(YEAR, HAUL_JOIN, LENGTH)) %>% # after this line is where I would incorporate a different sample size feature. would need to set YAGMH_SFREQ to requested sample size.
    tidytable::mutate(YAGMH_SFREQ = base::sum(SUM_FREQUENCY), .by = c(YEAR, HAUL_JOIN)) %>%
    tidytable::left_join(length_DT %>%
                           tidytable::distinct(YEAR, HAUL_JOIN, .keep_all = TRUE) %>%
                           tidytable::select(-LENGTH, -YAGMH_SFREQ))
}
# for testing
# length_DT = .freq










