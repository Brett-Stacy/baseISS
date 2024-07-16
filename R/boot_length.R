#' Resample length frequency data w/replacement.
#'
#' @param resampled_hauls resampled hauls input data table. Data table format input same as length_DT but with only resampled hauls and associated data, plus a unique identifier for resampled HAUL_JOIN called hauljoin_unique
#'
#' @return data table of resampled length frequencies by YEAR, HAUL_JOIN. Data table format output same as length_DT to be ready for expansion.
#'
#' @export
#'
# TESTING
resampled_hauls = .joined_hauls
boot_length = function(resampled_hauls) {
  resampled_hauls %>%
    data.table() %>%
    data.table::setkey(hauljoin_unique) -> test
    # tidytable::mutate(LENGTH = comp_sample(LENGTH, n = .N), .by = c(YEAR, hauljoin_unique)) # NEED TO CHANGE THIS TO INCLUDE SUM_FREQUENCY!!!
    tidytable::mutate(test, comp_sample2(test), .by = c(YEAR, hauljoin_unique))
}



# mine
samp_func3 = function(x2, DT) {
  data.table::setkey(DT, HAUL_JOIN)
  purrr::map(.x = x2, .f = function(x1) comp_sample(DT[x1][["LENGTH"]] %>% rep(DT[x1][["SUM_FREQUENCY"]]), replace = T)) # with frequency (correct)
}





boot_length <- function(lfreq_un) {

  # combine sex-length to common id - bootstrap based on year, species, haul then split back apart
  lfreq_un %>%
    tidytable::mutate(sex_ln = paste0(sex, "-", length)) %>%
    tidytable::mutate(sex_ln = sample(sex_ln, .N, replace = TRUE), .by= c(year, species_code, hauljoin)) %>%
    tidytable::separate(sex_ln, c('sex', 'length'), sep = '-', convert = TRUE) -> .lfreq_un
  # add combined sex resampled data
  .lfreq_un %>%
    tidytable::bind_rows(.lfreq_un %>%
                           tidytable::mutate(sex = 0))

}













