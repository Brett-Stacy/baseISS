# First try booting trip, haul, length with seperate switches.

iters = 3
lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP_STRATA.RDS")
yrs = 2020
boot.trip = TRUE # try a dot "." for switches when there is already exists a function with "_"
boot.haul = TRUE
boot.length = TRUE
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


saveRDS(.output, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/ISS_", iters, "iters_output_", Sys.Date(), ".RDS"))


