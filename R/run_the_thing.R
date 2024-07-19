iters = 10
lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/y2_ebs_pcod_Brett.RDS")
yrs = 2015
boot_thl = TRUE


tictoc::tic()
fishery_iss(iters = iters,
            lfreq_data = lfreq_data,
            yrs = yrs,
            boot_thl = boot_thl)
tictoc::toc()

