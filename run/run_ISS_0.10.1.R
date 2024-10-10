# 3x3 Grid. 10, 20, 30 length samples per haul X none, haul_only, haul_YAGM weighting factors. no sampling strata expansion

rm(list = ls())
run_name = "3x3_grid_V2"

lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP_STRATA.RDS")
library(tidytable)
library(baseISS)


### Global
iters_global = 200
samples_global = c(10, 20, 30)
expansion_global = list(NULL, "haul_numbers", c("haul_numbers", "month_numbers"))
expansion_names_global = c("NULL", "haul_numbers", c("haul_month_numbers"))


# Loop All
out = list()
for(i in 1:length(samples_global)){
  out[[paste0("samples_", samples_global)[i]]] = list()
  for(j in 1:length(expansion_global)){

    samples = samples_global[i]
    expansion = expansion_global[[j]]

    tictoc::tic()
    fishery_iss(species_code = "202",
                area_code = "EBS",
                length_based = TRUE,
                iters = iters_global,
                freq_data = lfreq_data,
                yrs = 1999,
                post_strata = NULL,
                minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30),
                new_length_N = list(type = "value", bound = NULL, amount = samples),
                boot.trip = TRUE,
                boot.haul = TRUE,
                boot.length = TRUE,
                boot.age = FALSE,
                expand.by.sampling.strata = FALSE,
                expansion_factors = expansion) -> .output
    tictoc::toc()
    out[[paste0("samples_", samples_global)[i]]][[paste0("expansion_", expansion_names_global)[j]]] = .output

  }
}

saveRDS(out, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/", run_name, "_ISS_", iters_global, "_iters_", Sys.Date(), ".RDS"))










