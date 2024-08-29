# Age
run_name = "age_V1"

lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_sex_ebs_pcod_Steve_TRIP_STRATA.RDS")
library(tidytable)
library(baseISS)
# alfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_sex_ebs_pcod_Steve_TRIP_STRATA.RDS")


length_based = TRUE # if FALSE, then age_based. Try TRUE first to test if still works.
iters = 2
freq_data = lfreq_data # try with lfreq first.
yrs = NULL
post_strata = list(strata = c("SEX")) # try SEX post-strata - works
boot.trip = T
boot.haul = T
boot.length = T
boot.age = F
expand.by.sampling.strata = TRUE
expand_using_weighting_factors = TRUE


tictoc::tic()
fishery_iss(length_based = length_based,
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


