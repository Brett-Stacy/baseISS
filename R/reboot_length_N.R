#' Change the haul-level sample size of resampled lengths
#'
#' @description
#' Function similar to boot_length() to allow resampling of resampled length data based on user-defined options for adjusting haul-level sample size.
#'
#' @param length_DT length frequency input data frame output from boot_length().
#' @param new_length_N user-defined sample size adjustment options defined in fishery_iss()
#'
#' @return length frequency data table including resampled length frequencies as LENGTH and associated data
#'
#' @export
#'
reboot_length_N = function(length_DT,
                           new_length_N = NULL)
  {

  # uncount the resampled data frame
  length_DT %>%
    tidytable::uncount(SUM_FREQUENCY) -> .length_DT

  .length_DT %>%
    tidytable::summarise(LENGTH = generic_sample_change_length_N(flex.vec = LENGTH,
                                                      new_length_N = new_length_N), .by = c(YEAR, HAUL_JOIN)) %>%
    tidytable::summarise(SUM_FREQUENCY = n(base::unique(LENGTH)), .by = c(YEAR, HAUL_JOIN, LENGTH)) %>%
    tidytable::mutate(YAGMH_SFREQ = base::sum(SUM_FREQUENCY), .by = c(YEAR, HAUL_JOIN)) %>%
    tidytable::left_join(.length_DT %>%
                           tidytable::distinct(YEAR, HAUL_JOIN, .keep_all = TRUE) %>%
                           tidytable::select(-LENGTH, -YAGMH_SFREQ)) -> .new_length_DT



  ######################## old:

#
#
#   .length_DT %>%
#     summarise(LENGTH = generic_sample_change_length_N(LENGTH,
#                                                       new_length_N = new_length_N), .by = c(YEAR, HAUL_JOIN)) %>%
#     tidytable::left_join(.length_DT %>%
#                            tidytable::select(-LENGTH) %>%
#                            tidytable::distinct(YEAR, HAUL_JOIN, .keep_all = TRUE)) %>%
#     tidytable::summarise(SUM_FREQUENCY = n(base::unique(LENGTH)), .by = c(YEAR, HAUL_JOIN, LENGTH)) %>% # after this line is where I would incorporate a different sample size feature. would need to set YAGMH_SFREQ to requested sample size.
#     tidytable::mutate(YAGMH_SFREQ = base::sum(SUM_FREQUENCY), .by = c(YEAR, HAUL_JOIN)) %>%
#     tidytable::left_join(.length_DT %>%
#                            tidytable::distinct(YEAR, HAUL_JOIN, .keep_all = TRUE) %>%
#                            tidytable::select(-LENGTH, -YAGMH_SFREQ)) -> .new_length_DT
#
#

  return(.new_length_DT)

}
# for testing
# length_DT = .freq
# generic_sample_change_length_N(.length_DT[HAUL_JOIN=="H1012896",]$LENGTH, new_length_N = new_length_N)








