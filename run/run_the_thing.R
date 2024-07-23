iters = 100
# lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/y2_ebs_pcod_Brett.RDS")
lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/y2_ebs_pcod_Brett_TRIP.RDS")
yrs = NULL
boot_thl = TRUE


tictoc::tic()
fishery_iss(iters = iters,
            lfreq_data = lfreq_data,
            yrs = yrs,
            boot_thl = boot_thl) -> .output
tictoc::toc()


saveRDS(.output, file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/ISS_output_to_email_7_23_24.RDS")


