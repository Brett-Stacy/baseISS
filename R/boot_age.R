#' Resample age frequency data w/replacement.
#'
#' @param age_DT age frequency input data table. Can be the output object from boot_trip() if boot.trip == true, or boot_haul() if boot.haul == true, or both
#'
#' @return age frequency data table including resampled age frequencies as AGE and associated data
#'
#' @export
#'
boot_age = function(age_DT) {
  age_DT %>%
    # tidytable::uncount(SUM_FREQUENCY) %>% # comment this out because the input data table does not have SUM_FREQUENCY at this point. i.e., the data table is already flattened.
    tidytable::mutate(AGE = generic_sample(AGE, n.samples = .N), .by = c(YEAR, HAUL_JOIN)) %>%  # should this include .by trip join?? I don't think so because I think it would give the same answer
    tidytable::summarise(SUM_FREQUENCY = n(base::unique(AGE)), .by = c(YEAR, HAUL_JOIN, AGE)) %>% # YAGMH_SFREQ customization after this once solidify age booting process.
    tidytable::left_join(age_DT %>%
                           tidytable::distinct(YEAR, HAUL_JOIN, .keep_all = TRUE) %>%
                           tidytable::select(-AGE))
}











