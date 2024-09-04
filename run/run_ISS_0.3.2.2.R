# Intermediate functionality adjustment - user defined minimum sample size to filter by. User chooses resolution and sample size to keep data greater than. - tested: works
# otherwise identical to age_V3
run_name = "sample_size_V1"

lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_sex_ebs_pcod_Steve_TRIP_STRATA.RDS")
library(tidytable)
library(baseISS)
# alfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_sex_ebs_pcod_Steve_TRIP_STRATA.RDS")


# fake age
lfreq_data %>%
  tidytable::mutate(AGE = LENGTH) %>%
  tidytable::select(-LENGTH) -> lfreq_data




species_code = "202"
area_code = "EBS"
length_based = FALSE
iters = 2
freq_data = lfreq_data
yrs = NULL
post_strata = list(strata = c("SEX"))
minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30) # test with EBS Pcod standard filter for length
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
            minimum_sample_size = minimum_sample_size,
            boot.trip = boot.trip,
            boot.haul = boot.haul,
            boot.length = boot.length,
            boot.age = boot.age,
            expand.by.sampling.strata = expand.by.sampling.strata,
            expand_using_weighting_factors = expand_using_weighting_factors) -> .output
tictoc::toc()
.output


saveRDS(.output, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/", run_name, "_ISS_", iters, "iters_output_", Sys.Date(), ".RDS"))


