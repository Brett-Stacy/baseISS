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
# freq_data = lfreq_data
# yrs = 1999
# post_strata = list(strata = "GEAR", nested = FALSE)
# minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30) # throw minimum sample size back in because we are back to testing with length
# new_length_N = list(type = "value", bound = NULL, amount = 20)
# boot.trip = T
# boot.haul = T
# boot.length = T
# boot.age = F
# expand.by.sampling.strata = TRUE
# expansion_factors = c("haul_numbers", "month_numbers")


tictoc::tic()
fishery_iss(species_code = "202",
            area_code = "EBS",
            length_based = TRUE,
            iters = 2,
            freq_data = lfreq_data,
            yrs = 1999,
            post_strata = list(strata = c("GEAR", "MONTH"), nested = TRUE),
            minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30),
            new_length_N = list(type = "value", bound = NULL, amount = 20),
            boot.trip = TRUE,
            boot.haul = TRUE,
            boot.length = TRUE,
            boot.age = FALSE,
            expand.by.sampling.strata = TRUE,
            expansion_factors = c("haul_numbers", "month_numbers")) -> .output
tictoc::toc()
.output


saveRDS(.output, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/", run_name, "_ISS_", iters, "iters_output_", Sys.Date(), ".RDS"))




















