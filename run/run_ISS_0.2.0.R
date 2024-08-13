# First try booting trip, haul, length with separate switches.
run_name = "separate_boot_switches"
iters = 2
lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP_STRATA.RDS")

yrs = NULL
boot.trip = T # use a dot "." for switches when there is already exists a function with "_" of the same name
boot.haul = F
boot.length = F
expand_by_sampling_strata = TRUE
expand_using_weighting_factors = TRUE


tictoc::tic()
fishery_iss(iters = iters,
            lfreq_data = lfreq_data,
            yrs = yrs,
            boot.trip = boot.trip,
            boot.haul = boot.haul,
            boot.length = boot.length,
            expand_by_sampling_strata = expand_by_sampling_strata,
            expand_using_weighting_factors = expand_using_weighting_factors) -> .output
tictoc::toc()
.output


saveRDS(.output, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/", run_name, "_ISS_", iters, "iters_output_", Sys.Date(), ".RDS"))


