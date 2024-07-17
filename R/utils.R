comp_sample = function(length_comps, n.samples) length_comps[sample.int(length(length_comps), n = n.samples, replace = TRUE)]



# TESTING:
DT = resampled_hauls[YEAR==1991 & hauljoin_unique==1,] %>%
  data.table() %>%
  data.table::setkey(hauljoin_unique)
n.samples = .N
comp_sample2 = function(DT) {
  DT %>%
    tidytable::uncount(SUM_FREQUENCY) %>%
    tidytable::mutate(LENGTH = comp_sample(LENGTH, n.samples = .N), .by = c(YEAR, hauljoin_unique)) %>%
    tidytable::summarise(SUM_FREQUENCY = n(unique(LENGTH)), .by = c(YEAR, hauljoin_unique, LENGTH)) -> .resampled_lengths
    # tidytable::left_join(DT) %>%
    # tidytable::drop_na() # LEFT OFF HERE 7/16 1:54.

  DT %>%
    tidytable::distinct(YEAR, hauljoin_unique, .keep_all = T) %>%
    tidytable::select(-LENGTH, -SUM_FREQUENCY) %>%
    tidytable::right_join(.resampled_lengths)


}



resampled_hauls %>%
  data.table() %>%
  data.table::setkey(hauljoin_unique) -> DT
comp_sample2(DT)


