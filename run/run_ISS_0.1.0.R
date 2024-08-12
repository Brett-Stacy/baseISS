iters = 300
lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_ebs_pcod_Brett_TRIP_STRATA2.RDS")
yrs = NULL
boot_thl = TRUE
expand_by_sampling_strata = TRUE
expand_using_weighting_factors = TRUE


tictoc::tic()
fishery_iss(iters = iters,
            lfreq_data = lfreq_data,
            yrs = yrs,
            boot_thl = boot_thl,
            expand_by_sampling_strata = expand_by_sampling_strata,
            expand_using_weighting_factors = expand_using_weighting_factors) -> .output
tictoc::toc()


saveRDS(.output, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/ISS_", iters, "iters_output_", Sys.Date(), ".RDS"))


