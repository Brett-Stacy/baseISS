iters = 1000
# lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/y2_ebs_pcod_Brett.RDS")
# lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/y2_ebs_pcod_Brett_TRIP.RDS")
lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_ebs_pcod_Brett_TRIP_STRATA2.RDS")
yrs = NULL
boot_thl = TRUE
expand_by_sampling_strata = TRUE


tictoc::tic()
fishery_iss(iters = iters,
            lfreq_data = lfreq_data,
            yrs = yrs,
            boot_thl = boot_thl,
            expand_by_sampling_strata = expand_by_sampling_strata) -> .output
tictoc::toc()


saveRDS(.output, file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/ISS_1000iters_output_8_2_24.RDS")


