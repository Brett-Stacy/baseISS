#' Resample length frequency data w/replacement.
#'
#' @param resampled_hauls resampled hauls input data table. Data table format input same as length_DT but with only resampled hauls and associated data, plus a unique identifier for resampled HAUL_JOIN called hauljoin_unique
#'
#' @return data table of resampled length frequencies by YEAR, HAUL_JOIN. Data table format output same as length_DT to be ready for expansion.
#'
#' @export
#'
boot_length = function(resampled_hauls) {
  resampled_hauls %>%
    data.table() %>%
    data.table::setkey(hauljoin_unique) -> .temp_DT

  .temp_DT %>%
    tidytable::uncount(SUM_FREQUENCY) %>%
    tidytable::mutate(LENGTH = generic_sample(LENGTH, n.samples = .N), .by = c(YEAR, hauljoin_unique)) %>%
    tidytable::summarise(SUM_FREQUENCY = n(unique(LENGTH)), .by = c(YEAR, hauljoin_unique, LENGTH)) -> .resampled_lengths

  .temp_DT %>%
    tidytable::distinct(YEAR, hauljoin_unique, .keep_all = T) %>%
    tidytable::select(-LENGTH, -SUM_FREQUENCY) %>%
    tidytable::right_join(.resampled_lengths) %>%
    tidytable::mutate(WEIGHT1 = SUM_FREQUENCY/YAGMH_SFREQ)
}
# TESTING
# resampled_hauls = .joined_hauls












