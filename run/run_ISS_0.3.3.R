# Age - fourth integration, try with real age data. Modify the expansion, and figure out what to do with the _sfreq, yagmh, yagm, and weighting stuff.
run_name = "age_V4"

# lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_sex_ebs_pcod_Steve_TRIP_STRATA.RDS")
library(tidytable)
library(baseISS)
alfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_age_sex_ebs_pcod_Steve_TRIP_STRATA_V1.RDS")
alfreq_data$LENGTH = NULL # nullify length because it gets in the way when summarizing by age in boot_age.R.
alfreq_data$SEX = NULL # also nullify sex for now because it is complicating weight1 calculation in fishery_props (multiple sexes translates to repeated SUM_FREQUENCY values). This is only necessary for testing, and won't be necessary when stratifying by SEX. There is a stop error if SEX is included in the input data frame, but not requested to be post-stratified by.



species_code = "202"
area_code = "EBS"
length_based = FALSE # if FALSE, then age_based. Try FALSE here
iters = 2
freq_data = alfreq_data # use real age data
yrs = NULL
post_strata = list(strata = c("GEAR")) # try gear post-strata
minimum_sample_size = NULL # not implemented for age yet. no SFREQ stuff to filter minimal sample size by age yet.
boot.trip = T
boot.haul = T
boot.length = F
boot.age = T
expand.by.sampling.strata = TRUE
expand_using_weighting_factors = TRUE


tictoc::tic()
fishery_iss(species_code = species_code,
            area_code = area_code,
            length_based = length_based,
            iters = iters,
            freq_data = freq_data,
            yrs = yrs,
            post_strata = post_strata,
            boot.trip = boot.trip,
            boot.haul = boot.haul,
            boot.length = boot.length,
            boot.age = boot.age,
            expand.by.sampling.strata = expand.by.sampling.strata,
            expand_using_weighting_factors = expand_using_weighting_factors) -> .output
tictoc::toc()
.output


saveRDS(.output, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/", run_name, "_ISS_", iters, "iters_output_", Sys.Date(), ".RDS"))


