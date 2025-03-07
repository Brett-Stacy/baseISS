
rm(list = ls())
run_name = "paper_scenario_33.1"

lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP_STRATA.RDS")
library(tidytable)
library(baseISS)


### Global
iters_global = 500
proportion_global = seq(0.1, 0.9, by = .1)
type_global = list("trip", "haul")
type_names_global = c("trip", "haul")


# Loop All
out = list()
for(i in 1:length(proportion_global)){
  out[[paste0("proportion_", proportion_global)[i]]] = list()
  for(j in 1:length(type_global)){

    .proportion = proportion_global[i]
    .type = type_global[[j]]

    tictoc::tic()
    fishery_iss(species_code = "202",
                area_code = "EBS",
                length_based = TRUE,
                iters = iters_global,
                freq_data = lfreq_data,
                yrs = NULL,
                bin = NULL,
                plus_len = NULL,
                post_strata = NULL,
                minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30),
                new_trip_N = if(.type=="trip") {list(type = "proportion", amount = .proportion, replace = FALSE)} else{NULL},
                new_haul_N = if(.type=="haul") {list(type = "proportion", amount = .proportion, replace = FALSE)} else{NULL},
                new_length_N = NULL,
                max_length = 150,
                boot.trip = TRUE,
                boot.haul = TRUE,
                boot.length = TRUE,
                boot.age = FALSE,
                expand.by.sampling.strata = TRUE,
                expansion_factors = c("haul_numbers", "month_numbers"),
                save_data_frame = FALSE) -> .output
    tictoc::toc()
    out[[paste0("proportion_", proportion_global)[i]]][[paste0("type_", type_names_global)[j]]] = .output

  }
}

saveRDS(out, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/paper_output/", run_name, "_ISS_", iters_global, "_iters_", Sys.Date(), ".RDS"))










