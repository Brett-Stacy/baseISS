# custom length bins

rm(list = ls())
run_name = "length_bins_V1"
iterations = 1

lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP_STRATA.RDS")
library(tidytable)
library(baseISS)




tictoc::tic()
fishery_iss(species_code = "202",
            area_code = "EBS",
            length_based = TRUE,
            iters = 1,
            freq_data = lfreq_data,
            yrs = 1999,
            bin = c(5, 10, 20, 35, 60),
            plus_len = NULL,
            post_strata = NULL,
            minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30),
            new_length_N = list(type = "value", bound = NULL, amount = 20),
            max_length = "data_derived",
            boot.trip = TRUE,
            boot.haul = TRUE,
            boot.length = TRUE,
            boot.age = FALSE,
            expand.by.sampling.strata = TRUE,
            expansion_factors = c("haul_numbers", "month_numbers")) -> .output
tictoc::toc()
.output


saveRDS(.output, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/", run_name, "_ISS_", iterations, "iters_output_", Sys.Date(), ".RDS"))




















