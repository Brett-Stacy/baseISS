# Based on 0.3.2. Incorporate YAGMH_SFREQ recalculation into booting process. Do it for length first.
run_name = "custom_YAGMH_SFREQ"

lfreq_data_test = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_sex_ebs_pcod_Steve_TRIP_STRATA.RDS")
library(tidytable)
library(baseISS)
# alfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_sex_ebs_pcod_Steve_TRIP_STRATA.RDS")


# # fake age
# lfreq_data_test %>%
#   tidytable::mutate(AGE = LENGTH) %>%
#   tidytable::select(-LENGTH) -> lfreq_data_test




species_code = "202"
area_code = "EBS"
length_based = TRUE # true for this one
iters = 2
freq_data = lfreq_data_test # use length data
yrs = NULL
post_strata = list(strata = c("SEX")) # try SEX post-strata
minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30)
boot.trip = T
boot.haul = T
boot.length = F
boot.age = T
expand.by.sampling.strata = TRUE
expand_using_weighting_factors = TRUE


tictoc::tic()
fishery_iss(species_code = species_code,
            area_code = area_code,
            length_based = length_based,
            iters = iters,
            freq_data = freq_data,
            yrs = yrs,
            post_strata = post_strata,
            boot.trip = boot.trip,
            boot.haul = boot.haul,
            boot.length = boot.length,
            boot.age = boot.age,
            expand.by.sampling.strata = expand.by.sampling.strata,
            expand_using_weighting_factors = expand_using_weighting_factors) -> .output
tictoc::toc()
.output


saveRDS(.output, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/", run_name, "_ISS_", iters, "iters_output_", Sys.Date(), ".RDS"))


