iters = 10
lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/y2_ebs_pcod_Brett.RDS")
yrs = NULL
boot_thl = TRUE
fishery_iss(iters = iters,
            lfreq_data = lfreq_data,
            yrs = yrs,
            boot_thl = boot_thl)
