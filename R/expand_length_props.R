#' Expand sample level proportions-at-length to population level
#'
#' @description
#' takes length frequency data and expands it into fished population proportions at length using the weightings from the relevant data. The relevant data can be the og data or bootstrapped data.
#'
#' @param length_DT data table of length frequency data in the form of EBS Pcod y2 object
#' @param expand_by_sampling_strata expand by observer sampling strata? If TRUE, then an additional weighting factor is calculated and applied to WEIGHT1 based on the number of fish caught in each sampling stratum.
#'
#' @export
#'
expand_length_props = function(length_DT,
                               expand_by_sampling_strata = FALSE) {


  # Add in sampling strata weighting functionality ----
  if(isTRUE(expand_by_sampling_strata)){
    print("expand by sampling strata activated")
    length_DT %>%
      tidytable::summarise(YAGMH_SNUM, .by = c(YEAR, SAMPLING_STRATA_NAME, hauljoin_unique)) %>% # this will currently only work for bootstrapped lengths because those length_DT objects have hauljoin_unique
      tidytable::distinct() %>%
      tidytable::mutate(YS_TNUM = base::sum(YAGMH_SNUM), .by = c(YEAR, SAMPLING_STRATA_NAME)) %>%
      tidytable::summarise(YS_TNUM, .by = c(YEAR, SAMPLING_STRATA_NAME)) %>%
      tidytable::distinct() %>%
      tidytable::mutate(WEIGHT_YS = YS_TNUM/base::sum(YS_TNUM), .by = YEAR) %>%
      tidytable::right_join(length_DT) %>%
      tidytable::mutate(WEIGHT1 = WEIGHT1*WEIGHT_YS) -> length_DT
  }


  # Expansion copied from EBS Pcod code 2023 ----
  y2 = length_DT

  y3<- y2[,c("YEAR","GEAR","AREA2","MONTH","CRUISE",
             "HAUL_JOIN", "LENGTH", "SUM_FREQUENCY", "YAGMH_SNUM",
             "YAGMH_SFREQ","YAGM_SFREQ", "YG_SFREQ","Y_SFREQ","YAGM_TNUM","YG_TNUM","Y_TNUM","YAGMH_SNUM",
             "YAGM_SNUM","YG_SNUM","YG_SNUM","Y_SNUM","WEIGHT1","WEIGHT2","WEIGHT3","WEIGHT4")]     # get rid of some unneeded variables

  y3$WEIGHTX<-y3$WEIGHT1*y3$WEIGHT2*y3$WEIGHT4   ## weight of individual length sample for single fishery model. # multiply individual observation weight at haul level by weight of the haul by the weight of the year/area/gear/month. So this should give the weight each observation has, scaled by the haul weight and month/gear/year/area weight
  # y3$WEIGHTX_GEAR<-y3$WEIGHT1*y3$WEIGHT2*y3$WEIGHT3 # similar to previous but including gear weights

  y4<-y3[YAGM_SFREQ>30][,list(WEIGHT=sum(WEIGHTX)),by=c("LENGTH","YEAR")]  ## setting minumal sample size to 30 lengths for Year, area, gear, month strata. # sample size here means the number of samples taken by observers in the YAGM combination. this reduced nrow by about 1000. this line also creates a new variable WEIGHT, which is the sum of WEIGHTX across length and year. i.e., the weight of each length for every year.
  # y4.1<-y3[YAGM_SFREQ>30][,list(WEIGHT_GEAR=sum(WEIGHTX_GEAR)),by=c("LENGTH","GEAR","YEAR")]  ## setting minimal sample size to 30 lengths for Year, area, gear, month strata. to be used in the multiple gear fisheries section below.


  y5<-y4[,list(TWEIGHT=sum(WEIGHT)),by=c("YEAR")] # TWEIGHT is I think the total weight summed across length bins for every year. sum(TWEIGHT) = 1.9. Shouldn't this sum to 1??
  y5=merge(y4,y5) # merge the individual length weights with their respective year weights.
  y5$FREQ<-y5$WEIGHT/y5$TWEIGHT # RESULT! This is the preliminary proportions at length. They sum to 1 for every year. the FREQuency, or relative weight, between length bins to the total annual weight.
  y6<-y5[,-c("WEIGHT","TWEIGHT")] # saving a version with just FREQ

  grid<-data.table(expand.grid(YEAR=unique(y5$YEAR),LENGTH=1:200)) # make a grid for every year, have a length bin by centemeter from 1 to max length
  y7<-merge(grid,y6,all.x=TRUE,by=c("YEAR","LENGTH")) # merge the grid with y6, which is the expanded frequency of proportions for each length bin observed for each year.
  y7[is.na(FREQ)]$FREQ <-0                                  # RESULT! ## this is the proportion at length for an aggregated-gear fishery. # The NAs are where there were no observations for that length bin in that year so call them zero. This is what must be input into the assessment model.



  return(y7)




}


# TESTING
# length_DT = .lfreq










