
rm(list = ls())
run_name = "paper_scenario_30.1"

lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP_STRATA.RDS")
library(tidytable)
library(baseISS)


### Global
iters_global = 500
expansion_global = list(NULL, "haul_numbers", c("haul_numbers", "month_numbers"))
expansion_names_global = c("NULL", "haul_numbers", c("haul_month_numbers"))


# Loop All
out = list()
  for(j in 1:length(expansion_global)){

    expansion = expansion_global[[j]]

    tictoc::tic()
    fishery_iss(species_code = "202",
                area_code = "EBS",
                length_based = TRUE,
                iters = iters_global,
                freq_data = lfreq_data,
                yrs = 1999,
                bin = NULL,
                plus_len = NULL,
                post_strata = NULL,
                minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30),
                new_trip_N = NULL,
                new_haul_N = NULL,
                new_length_N = NULL,
                boot.trip = TRUE,
                boot.haul = TRUE,
                boot.length = TRUE,
                boot.age = FALSE,
                expand.by.sampling.strata = TRUE,
                expansion_factors = expansion,
                save_data_frame = FALSE) -> .output
    tictoc::toc()
    out[[paste0("expansion_", expansion_names_global)[j]]] = .output

  }


saveRDS(out, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/paper_output/", run_name, "_ISS_", iters_global, "_iters_", Sys.Date(), ".RDS"))










