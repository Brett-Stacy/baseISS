
rm(list = ls())
run_name = "paper_scenario_25.2"

lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP_STRATA.RDS")
library(tidytable)
library(baseISS)


### Global
iters_global = 200
samples_global = c(1, 5, 10, 15, 20, 25, 30, 35)
# proportion_global = c(0.25, 0.50, 0.75, 1.25, 1.50, 1.75, 2.00)
proportion_global = list(haul = c(.5, .5, .75, .75, 1.25, 1.25), trip = c(.5, .75, .5, .75, .5, .75))




# Loop All
out = list()
for(i in 1:length(samples_global)){
  out[[paste0("samples_", samples_global)[i]]] = list()
  for(j in 1:length(proportion_global$haul)){

    samples = samples_global[i]
    .proportion_haul = proportion_global$haul[j]
    .proportion_trip = proportion_global$trip[j]

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
                new_trip_N = list(type = "proportion", amount = .proportion_trip),
                new_haul_N = list(type = "proportion", amount = .proportion_haul),
                new_length_N = list(type = "value", bound = NULL, amount = samples),
                max_length = 150,
                boot.trip = TRUE,
                boot.haul = TRUE,
                boot.length = TRUE,
                boot.age = FALSE,
                expand.by.sampling.strata = TRUE,
                expansion_factors = c("haul_numbers", "month_numbers"),
                save_data_frame = FALSE) -> .output
    tictoc::toc()
    out[[paste0("samples_", samples_global)[i]]][[paste0(paste0("haul_", proportion_global$haul)[j], "_", paste0("trip_", proportion_global$trip)[j])]] = .output

  }
}

saveRDS(out, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/paper_output/", run_name, "_ISS_", iters_global, "_iters_", Sys.Date(), ".RDS"))










