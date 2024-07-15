



# This function takes resampled length frequencies and amends them to the DT for entry into the expanded_length_props.R function.
# Here, the goal is to replace the LENGTH and SUM_FREQUENCY columns in the DT with the resampled values.
# Other things that need to happen are:
#   - merge the og_DT with the resamples by HAUL_JOIN
#   - Recalculate WEIGHT1


amend_DT_with_resamples = function(resampled_lengths) {

}

# ----
# Subset y2 to only include the relevant data IN PREVIOUS STEP IN BOOT_. This is necessary for the bootstrapped data table that comes from the boot_ scripts. OR maybe the boot_ scripts should return the table already subsetted. In this case, the DT used as the input function arguement for boot_ should NOT include weight1, only the other weights. It should also not include any columns used to calculate weight1 as these need to be redone for each bootstrap iteration.

# ----
# Recalculate WEIGHT1 somewhere!!!

length_DT[, LENGTH] =
  length_DT[, SUM_FREQUENCY] =

  length_DT[, WEIGHT1 := NULL]
  y2$WEIGHT1<-y2$SUM_FREQUENCY/y2$YAGMH_SFREQ  ## OBSERVER BASED. individual weighting of length bins in length sample at the haul level. # weight here refers to the leverage weight the observation will have in later analysis I think. i.e., the proportion of lengths l observed to the total number of lengths taken in the haul it came from.




  # may not need ----

  # The below sums add up the frequency of lengths observed at each strata level that matches the strata levels in CATCHT4 above. They will be merged.
  Length<-Length[,list(SUM_FREQUENCY=sum(SUM_FREQUENCY)),by=c("SPECIES","YEAR","AREA2","GEAR","MONTH","CRUISE","VES_AKR_ADFG","HAUL_JOIN","LENGTH","YAGMH_STONS","YAGMH_SNUM")] # sum the frequency of each observed length at haul level, summed over the excluded variables from this list: SEX. Also get rid of variables no longer needed that are the same for each flattened observation: EXTRAPOLATED_WEIGHT, SOURCE, AREA, QUARTER, NUMB





