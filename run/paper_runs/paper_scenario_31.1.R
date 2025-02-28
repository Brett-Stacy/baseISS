
rm(list = ls())
run_name = "paper_scenario_31.1"

lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP_STRATA.RDS")
library(tidytable)
library(baseISS)


### Global
iters_global = 500
samples_global = c(1, 5, 10, 15, 20)
data_global = list("H_P", "H")
data_names_global = c("H_P", "H")


# Loop All
out = list()
for(i in 1:length(samples_global)){
  out[[paste0("samples_", samples_global)[i]]] = list()
  for(j in 1:length(data_global)){

    samples = samples_global[i]
    .data = data_global[[j]]

    if(.data=="H_P"){
      .lfreq_data = lfreq_data
    }else{
      .lfreq_data = lfreq_data %>% tidytable::filter(substr(HAUL_JOIN, 1, 1)=="H")
    }

    tictoc::tic()
    fishery_iss(species_code = "202",
                area_code = "EBS",
                length_based = TRUE,
                iters = iters_global,
                freq_data = .lfreq_data,
                yrs = 1999,
                bin = NULL,
                plus_len = NULL,
                post_strata = NULL,
                minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30),
                new_trip_N = NULL,
                new_haul_N = NULL,
                new_length_N = list(type = "value", bound = "minimum", amount = samples, replace = FALSE),
                boot.trip = TRUE,
                boot.haul = TRUE,
                boot.length = TRUE,
                boot.age = FALSE,
                expand.by.sampling.strata = TRUE,
                expansion_factors = c("haul_numbers", "month_numbers"),
                save_data_frame = FALSE) -> .output
    tictoc::toc()
    out[[paste0("samples_", samples_global)[i]]][[paste0("data_", data_names_global)[j]]] = .output

  }
}

saveRDS(out, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/paper_output/", run_name, "_ISS_", iters_global, "_iters_", Sys.Date(), ".RDS"))




















