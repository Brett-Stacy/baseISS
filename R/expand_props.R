#' Expand species-specific sample level proportions-at-length or -age to population level
#'
#' @description
#' This is intended to be a large function that consists of many conditional statements, each of which pertains to a unique species/area expansion method. The internals of the conditional statements can eventually turn into many species/area/length/age specific functions housed in another script. Takes length or age frequency data and expands it into fished population proportions at length or age using the weightings from the relevant data. The relevant data can be the og data or bootstrapped data.
#'
#' @param species_code species number code. Used for specific expansion. This is not (yet) an input data filter, it is only for output naming convention and to condition on expansion method.
#' @param area_code area character code. Used for specific expansion. This is not (yet) an input data filter, it is only for output naming convention and to condition on expansion method.
#' @param length_based Boolean. If TRUE, then calculate length iss. if FALSE, then calculate age iss.
#' @param freq_data length or age frequency input data frame
#' @param minimum_sample_size list(resolution = character string, size = integer). If NULL, then no minimum sample size. If not NULL, The sample size at the chosen resolution (must be column in freq_data, e.g., YAGM_SFREQ for EBS Pcod) for which to filter out data that does not meet the minimum sample size requested. Example: minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30). Note that this filters to keep only samples GREATER than 30 at the YAGM resolution.
#' @param max_length integer or "data_derived" (default). Provides the maximum length bin to record proportions-at-length. Integer values must be equal to or greater than the maximum length observed in the data (this will be changed once a plus-group option is coded in the future). "data_derived" forces the maximum length to be calculated from the data.
#' @param boot.length Boolean. Resample lengths w/replacement? (default = FALSE). FALSE to all three boots will return og proportions-at-length. In this function, this activates a switch to calculate SUM_FREQUENCY for og_props.
#' @param expand.by.sampling.strata MAKE THIS GENERIC IN FUTURE. expand by observer sampling strata? If TRUE, then an additional weighting factor is calculated and applied to WEIGHT1 based on the number of fish caught in each sampling stratum.
#' @param expansion_factors expansion weighting factors to apply to the proportions. If NULL, then no expansion factors are applied. Otherwise, the conditional options coded in expand_props.R are "haul_numbers" or "haul_numbers" and "month_numbers". Consider improving/generalizing this by calling it expansion_weighting_factors = list(type = c("weight", "number"), factors = c("haul", "area", "month", "gear", etc.) to give the user the option of what aspects (columns) of the data to expand by and do it by weight of fish or number of fish in those categories.
#'
#' @export
#'
expand_props = function(species_code,
                        area_code,
                        length_based = TRUE,
                        freq_data,
                        minimum_sample_size = NULL,
                        max_length,
                        boot.length = FALSE,
                        expand.by.sampling.strata = FALSE,
                        expansion_factors)
  {


  ########## EBS PCOD (202) ##########
  ##### Length
  if(species_code==202 & area_code=="EBS" & base::isTRUE(length_based)){

    print("Expansion for species 202 in area BS")


    # Add in SUM_FREQUENCY if it doesn't already exist (for og_props situation) ----
    # uncount the data frame if it is compressed by count of length or age, i.e., flatten the data frame. This only impacts length-only data frames because age input data frames should always be flattened. This avoids uncounting it in every resampling iteration. Work with the SUM_FREQUENCY column name for now, may need to change this with alternative input data frames.
    if(!("SUM_FREQUENCY" %in% base::names(freq_data)) & base::isTRUE(length_based) & base::isFALSE(boot.length)){ # applies only to og_props because boot.length==F only for og.
      freq_data %>%
        tidytable::summarise(SUM_FREQUENCY = n(base::unique(LENGTH)), .by = c(YEAR, HAUL_JOIN, LENGTH)) %>% # after this line is where I would incorporate a different sample size feature. would need to set YAGMH_SFREQ to requested sample size.
        tidytable::mutate(YAGMH_SFREQ = base::sum(SUM_FREQUENCY), .by = c(YEAR, HAUL_JOIN)) %>%
        tidytable::left_join(freq_data %>%
                               tidytable::distinct(YEAR, HAUL_JOIN, .keep_all = TRUE) %>%
                               tidytable::select(-LENGTH, -YAGMH_SFREQ)) -> freq_data
    }


    # Add in sampling strata weighting functionality ----
    if(isTRUE(expand.by.sampling.strata)){
      print("expand by sampling strata activated")
      freq_data %>%
        expand_by_sampling_strata() -> freq_data
    }


    # Expansion copied from EBS Pcod code 2023 ----
    y2 = freq_data

    y3<- y2[,c("YEAR","GEAR","AREA2","MONTH","CRUISE",
               "HAUL_JOIN", "LENGTH", "SUM_FREQUENCY", "YAGMH_SNUM",
               "YAGMH_SFREQ","YAGM_SFREQ", "YG_SFREQ","Y_SFREQ","YAGM_TNUM","YG_TNUM","Y_TNUM","YAGMH_SNUM",
               "YAGM_SNUM","YG_SNUM","YG_SNUM","Y_SNUM","WEIGHT1","WEIGHT2","WEIGHT3","WEIGHT4")]     # get rid of some unneeded variables


    if(is.null(expansion_factors)){
      y3$WEIGHTX<-y3$WEIGHT1
    }else if(all(expansion_factors=="haul_numbers")){
      y3$WEIGHTX<-y3$WEIGHT1*y3$WEIGHT2
    }else if(all(expansion_factors==c("haul_numbers", "month_numbers"))){
      y3$WEIGHTX<-y3$WEIGHT1*y3$WEIGHT2*y3$WEIGHT4
    }

    # if(base::isTRUE(expand_using_weighting_factors)){
    #   y3$WEIGHTX<-y3$WEIGHT1*y3$WEIGHT2*y3$WEIGHT4   ## weight of individual length sample for single fishery model. # multiply individual observation weight at haul level by weight of the haul by the weight of the year/area/gear/month. So this should give the weight each observation has, scaled by the haul weight and month/gear/year/area weight
    # }else{
    #   y3$WEIGHTX<-y3$WEIGHT1   ## do not apply weighting factors.
    # }
    # y3$WEIGHTX_GEAR<-y3$WEIGHT1*y3$WEIGHT2*y3$WEIGHT3 # similar to previous but including gear weights


    if(!is.null(minimum_sample_size)){ # user-defined minimum sample size
      y4<-y3[minimum_sample_size$resolution > minimum_sample_size$size][,list(WEIGHT=sum(WEIGHTX)),by=c("LENGTH","YEAR")]
    }else{
      y4<-y3[,list(WEIGHT=sum(WEIGHTX)),by=c("LENGTH","YEAR")]
    }


    y5<-y4[,list(TWEIGHT=sum(WEIGHT)),by=c("YEAR")] # TWEIGHT is I think the total weight summed across length bins for every year. sum(TWEIGHT) = 1.9. Shouldn't this sum to 1??
    y5=merge(y4,y5) # merge the individual length weights with their respective year weights.
    y5$FREQ<-y5$WEIGHT/y5$TWEIGHT # RESULT! This is the preliminary proportions at length. They sum to 1 for every year. the FREQuency, or relative weight, between length bins to the total annual weight.
    y6<-y5[,-c("WEIGHT","TWEIGHT")] # saving a version with just FREQ

    # implement user-defined maximum length bin for output grid:
    if(is.numeric(max_length)){
      grid<-data.table(expand.grid(YEAR=unique(y5$YEAR),LENGTH=1:max_length)) # make a grid for every year, have a length bin by centemeter from 1 to max length
      if(max_length < max(y5$LENGTH)) stop("user-defined maximum length bin must be at least as large as the maximum length observed in the data. Plus-group functionality is not yet developed.")
    }else if(max_length=="data_derived"){
      grid<-data.table(expand.grid(YEAR=unique(y5$YEAR),LENGTH=1:max(y5$LENGTH))) # make a grid for every year, have a length bin by centemeter from 1 to max length
    }
    y7<-merge(grid,y6,all.x=TRUE,by=c("YEAR","LENGTH")) # merge the grid with y6, which is the expanded frequency of proportions for each length bin observed for each year.
    y7[is.na(FREQ)]$FREQ <-0                                  # RESULT! ## this is the proportion at length for an aggregated-gear fishery. # The NAs are where there were no observations for that length bin in that year so call them zero. This is what must be input into the assessment model.



    return(y7)






##### Age
  }else if(species_code==202 & area_code=="EBS" & base::isFALSE(length_based)){
    warning("Age expansion for species 202 in area BS under development")

    #### IMPORTANT NOTES:
    ## In order to implement age expansion in the same fashion as the existing length expansion, the following columns to be resolved:
    # 1. YAGMH_SFREQ: Haul-level number of age samples. This, combined with SUM_FREQUENCY are used for length to calculate WEIGHT1: proportions at length in a haul.
    # 2. SUM_FREQUENCY: Haul-level number of samples at each observed age.
    # 3. WEIGHT1: SUM_FREQUENCY/YAGMH_SFREQ
    # 4. YAGM_SFREQ: Month-level number of age samples. This is used for length to filter out 30 or less samples at the end of the expansion.
    # 5+. Y..._SFREQ: Any-level number of age samples desired to filter out by a minimum sample size.
    ## These considerations also need to be addressed:
    # 1. How to treat SUM_FREQUENCY when there exists the same ages at different lengths in a haul?
    # 2. How to implement conditional age-at-length?


    ########## BETA: JUST USE THE EXPANSION FROM LENGTH. THIS IS FOR FAKE AGE DATA ONLY (LENGTH column in the lfreq data frame artificially changed to AGE)
    # Add in sampling strata weighting functionality ----
    if(isTRUE(expand.by.sampling.strata)){
      print("expand by sampling strata activated")
      print(paste0("boot.age = ", boot.age))
      freq_data %>%
        expand_by_sampling_strata() -> freq_data
    }


    # Expansion copied from EBS Pcod code 2023 ----
    y2 = freq_data

    y3<- y2[,c("YEAR","GEAR","AREA2","MONTH","CRUISE",
               "HAUL_JOIN", "AGE", "SUM_FREQUENCY", "YAGMH_SNUM",
               "YH_SFREQ","YAGM_TNUM","YG_TNUM","Y_TNUM","YAGMH_SNUM",
               "YAGM_SNUM","YG_SNUM","YG_SNUM","Y_SNUM","WEIGHT1","WEIGHT2","WEIGHT3","WEIGHT4")]     # get rid of some unneeded variables

    if(is.null(expansion_factors)){
      y3$WEIGHTX<-y3$WEIGHT1
    }else if(all(expansion_factors=="haul_numbers")){
      y3$WEIGHTX<-y3$WEIGHT1*y3$WEIGHT2
    }else if(all(expansion_factors==c("haul_numbers", "month_numbers"))){
      y3$WEIGHTX<-y3$WEIGHT1*y3$WEIGHT2*y3$WEIGHT4
    }

    # if(base::isTRUE(expand_using_weighting_factors)){
    #   y3$WEIGHTX<-y3$WEIGHT1*y3$WEIGHT2*y3$WEIGHT4   ## weight of individual length sample for single fishery model. # multiply individual observation weight at haul level by weight of the haul by the weight of the year/area/gear/month. So this should give the weight each observation has, scaled by the haul weight and month/gear/year/area weight
    # }else{
    #   y3$WEIGHTX<-y3$WEIGHT1   ## do not apply weighting factors.
    # }
    # y3$WEIGHTX_GEAR<-y3$WEIGHT1*y3$WEIGHT2*y3$WEIGHT3 # similar to previous but including gear weights

    if(!is.null(minimum_sample_size)){ # user-defined minimum sample size
      y4<-y3[minimum_sample_size$resolution > minimum_sample_size$size][,list(WEIGHT=sum(WEIGHTX)),by=c("AGE","YEAR")]
    }else{
      y4<-y3[,list(WEIGHT=sum(WEIGHTX)),by=c("AGE","YEAR")]
    }

    y5<-y4[,list(TWEIGHT=sum(WEIGHT)),by=c("YEAR")] # TWEIGHT is I think the total weight summed across length bins for every year. sum(TWEIGHT) = 1.9. Shouldn't this sum to 1??
    y5=merge(y4,y5) # merge the individual length weights with their respective year weights.
    y5$FREQ<-y5$WEIGHT/y5$TWEIGHT # RESULT! This is the preliminary proportions at length. They sum to 1 for every year. the FREQuency, or relative weight, between length bins to the total annual weight.
    y6<-y5[,-c("WEIGHT","TWEIGHT")] # saving a version with just FREQ

    grid<-data.table(expand.grid(YEAR=unique(y5$YEAR),AGE=1:200)) # make a grid for every year, have a length bin by centemeter from 1 to max length
    y7<-merge(grid,y6,all.x=TRUE,by=c("YEAR","AGE")) # merge the grid with y6, which is the expanded frequency of proportions for each length bin observed for each year.
    y7[is.na(FREQ)]$FREQ <-0                                  # RESULT! ## this is the proportion at length for an aggregated-gear fishery. # The NAs are where there were no observations for that length bin in that year so call them zero. This is what must be input into the assessment model.



    return(y7)
    ########## END BETA











    ########## Pollock (201) ##########
    ##### Length
  }else if(species_code==201 & area_code=="unknown" & base::isTRUE(length_based)){

    print("Expansion for species 201 in area unknown")

    # Add in SUM_FREQUENCY if it doesn't already exist (for og_props situation) ----
    # uncount the data frame if it is compressed by count of length or age, i.e., flatten the data frame. This only impacts length-only data frames because age input data frames should always be flattened. This avoids uncounting it in every resampling iteration. Work with the SUM_FREQUENCY column name for now, may need to change this with alternative input data frames.
    if(!("SUM_FREQUENCY" %in% base::names(freq_data)) & base::isTRUE(length_based) & base::isFALSE(boot.length)){ # applies only to og_props because boot.length==F only for og.
      freq_data %>%
        tidytable::summarise(SUM_FREQUENCY = n(base::unique(LENGTH)), .by = c(YEAR, HAUL_JOIN, LENGTH)) %>% # after this line is where I would incorporate a different sample size feature. would need to set YAGMH_SFREQ to requested sample size.
        tidytable::mutate(YAGMH_SFREQ = base::sum(SUM_FREQUENCY), .by = c(YEAR, HAUL_JOIN)) %>%
        tidytable::left_join(freq_data %>%
                               tidytable::distinct(YEAR, HAUL_JOIN, .keep_all = TRUE) %>%
                               tidytable::select(-LENGTH)) -> freq_data
    }


    # Add in sampling strata weighting functionality ----
    if(isTRUE(expand.by.sampling.strata)){
      print("expand by sampling strata activated")
      freq_data %>%
        expand_by_sampling_strata() -> freq_data
    }


    ### Expansion cobbled together from EBS Pcod weight1 for now (eventually enter real code) ----
    # copied from above: y2$WEIGHT1<-y2$SUM_FREQUENCY/y2$YAGMH_SFREQ
    freq_data %>%
      tidytable::mutate(WEIGHT1 = SUM_FREQUENCY/YAGMH_SFREQ) -> freq_data

    # copied from above: y3$WEIGHTX<-y3$WEIGHT1
    y3 = freq_data
    y3$WEIGHTX<-y3$WEIGHT1

    y4<-y3[,list(WEIGHT=sum(WEIGHTX)),by=c("LENGTH","YEAR")]

    y5<-y4[,list(TWEIGHT=sum(WEIGHT)),by=c("YEAR")] # TWEIGHT is I think the total weight summed across length bins for every year. sum(TWEIGHT) = 1.9. Shouldn't this sum to 1??
    y5=merge(y4,y5) # merge the individual length weights with their respective year weights.
    y5$FREQ<-y5$WEIGHT/y5$TWEIGHT # RESULT! This is the preliminary proportions at length. They sum to 1 for every year. the FREQuency, or relative weight, between length bins to the total annual weight.
    y6<-y5[,-c("WEIGHT","TWEIGHT")] # saving a version with just FREQ

    # implement user-defined maximum length bin for output grid:
    if(is.numeric(max_length)){
      grid<-data.table(expand.grid(YEAR=unique(y5$YEAR),LENGTH=1:max_length)) # make a grid for every year, have a length bin by centemeter from 1 to max length
      if(max_length < max(y5$LENGTH)) stop("user-defined maximum length bin must be at least as large as the maximum length observed in the data. Plus-group functionality is not yet developed.")
    }else if(max_length=="data_derived"){
      grid<-data.table(expand.grid(YEAR=unique(y5$YEAR),LENGTH=1:max(y5$LENGTH))) # make a grid for every year, have a length bin by centemeter from 1 to max length
    }
    y7<-merge(grid,y6,all.x=TRUE,by=c("YEAR","LENGTH")) # merge the grid with y6, which is the expanded frequency of proportions for each length bin observed for each year.
    y7[is.na(FREQ)]$FREQ <-0                                  # RESULT! ## this is the proportion at length for an aggregated-gear fishery. # The NAs are where there were no observations for that length bin in that year so call them zero. This is what must be input into the assessment model.



    return(y7)








  }else if(species_code!=202 & area_code!="EBS"){
    stop(paste("Expansion for species", species_code, "in area", area_code, "under development", sep = " "))

  }else if(is.null(species_code & is.null(area_code))){
    # DEVELOP GENERIC, REASONABLE EXPANSION FOR AGE AND LENGTH
    stop("Generic expansion method under development")
  }








}


# TESTING
# freq_data = .freq










