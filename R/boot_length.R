#' Resample length frequency data w/replacement.
#'
#' @param lfreq_un expanded length frequency data (one row per sample)
#'
#' @return dataframe of resampled length-sex pairs by year, species, and haul
#'
#' @export
#'
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




# mine
samp_func3 = function(x2, DT) {
  data.table::setkey(DT, HAUL_JOIN)
  purrr::map(.x = x2, .f = function(x1) comp_sample(DT[x1][["LENGTH"]] %>% rep(DT[x1][["SUM_FREQUENCY"]]), replace = T)) # with frequency (correct)
}



















