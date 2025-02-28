# Run a post-stratified run for testing combine by post strata functionality

rm(list = ls())
run_name = "post_strata_0.1.1"
iterations = 1

lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP_STRATA.RDS")
library(tidytable)
library(baseISS)




tictoc::tic()
fishery_iss(species_code = "202",
            area_code = "EBS",
            length_based = TRUE,
            iters = iterations,
            freq_data = lfreq_data,
            yrs = NULL,
            bin = NULL,
            plus_len = NULL,
            post_strata = list(strata = "GEAR", nested = FALSE),
            minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30),
            new_trip_N = NULL,
            new_haul_N = NULL,
            new_length_N = NULL,
            max_length = 150,
            boot.trip = TRUE,
            boot.haul = TRUE,
            boot.length = TRUE,
            boot.age = FALSE,
            expand.by.sampling.strata = TRUE,
            expansion_factors = c("haul_numbers", "month_numbers"),
            save_data_frame = TRUE) -> .output
tictoc::toc()
.output


saveRDS(.output, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/Post Stratified/", run_name, "_ISS_", iterations, "iters_output_", Sys.Date(), ".RDS"))



















