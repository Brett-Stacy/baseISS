#' Combine post-stratified ISS results
#'
#' @description
#' Combine the post-stratified ISS results by post-strata fish weight or numbers as weighted average. Includes evidence somewhere (DECIDE BEST PLACE) that states it was combined by post_strata and reports what the strata were and the method used to combine them.
#'
#' @param freq_data length or age frequency input data frame
#' @param out_stats output object from fishery_iss()
#'
#' @return out_stats object to be returned by fishery_iss() that includes one vector of ISS based on the weighted average between post-strata
#'
#' @export
#'
combine_post_strata = function(freq_data,
                               out_stats){

  # step 1: take out_stats and extract the ISS and proportions
  # step 2: take freq_data and separate in the same way as post_stratify()
  # step 3: add up weight or numbers from each unique haul_join in each strata, for each year. This can be a data frame with columns: year, "NAME1"_post_strata, "NAME2"_post_strata, etc. With totals in kg or numbers of fish and NAs where the post-strata was absent for that year.
  # Absent post-strata years will have to be treated as a special case in the weighted average. Probably have a conditional statement asking for NAs?
  # step 4: apply proportional weighting to the ISS and props from each strata and combine
  # step 5: figure out what to do with the rest of the auxiliary data, e.g., RSS. Perhaps just add a list element to the existing out_stats that says: $combined_post_strata with a sublist that says $by that equals weight or numbers e.g., $by_weight.
  # step 6: deal with column name discrepencies: EXTRAPOLATED_NUMBER is number of fish in haul for generic species download, but YAGMH_SNUM for EBS Pcod. There are different expand_by_sampling_strata functions because of this discrepency.
  # step 7: deal with lack of haul weight in generic data download. this is EXTRAPOLATED_WEIGHT that is NOT currently in the .sql download generic but can be found in DEBRIEFED_SPCOMP_MV

  return(out_stats)


}
