# Fix mistake. fix all instances where I mistakenly relied on global environment definition of function arguements.

rm(list = ls())
run_name = "fix_mistake_arguement_definitions_V1"

lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP_STRATA.RDS")
library(tidytable)
library(baseISS)



# species_code = "202"
# area_code = "EBS"
# length_based = TRUE # TRUE for length
# iters = 2
freq_data = lfreq_data
yrs = 1999
post_strata = NULL
minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30) # throw minimum sample size back in because we are back to testing with length
new_length_N = NULL
boot.trip = T
boot.haul = T
boot.length = T
boot.age = F
expand.by.sampling.strata = TRUE
# expand_using_weighting_factors = TRUE
expansion_factors = c("haul_numbers", "month_numbers")


tictoc::tic()
fishery_iss(species_code = "202",
            area_code = "EBS",
            length_based = TRUE,
            iters = 2,
            freq_data = freq_data,
            yrs = yrs,
            post_strata = post_strata,
            minimum_sample_size = minimum_sample_size,
            new_length_N = new_length_N,
            boot.trip = boot.trip,
            boot.haul = boot.haul,
            boot.length = boot.length,
            boot.age = boot.age,
            expand.by.sampling.strata = expand.by.sampling.strata,
            expansion_factors = expansion_factors) -> .output
tictoc::toc()
.output


saveRDS(.output, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/", run_name, "_ISS_", iters, "iters_output_", Sys.Date(), ".RDS"))




















