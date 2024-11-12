# Generic '202' download capability.

rm(list = ls())
run_name = "generic_202_V1"
iterations = 1

lfreq_data_non_generic = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP_STRATA.RDS")
lfreq_data_generic = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/species_202_generic.RDS")
library(tidytable)
library(baseISS)


# Explore differences in curated vs generic data sets
lfreq_data_non_generic %>%
  glimpse()

lfreq_data_generic %>%
  glimpse()


# processing generic to make it work
lfreq_data_generic$SEX = NULL

# some things need to be characters instead of numeric
lfreq_data_generic$JOIN_KEY %>% class()
lfreq_data_generic %>% # this step reformats long number values to non-scientific and automatically changes their class to character.
  tidytable::mutate(JOIN_KEY = JOIN_KEY %>%
                      format(scientific = FALSE),
                    HAUL_JOIN = HAUL_JOIN %>%
                      format(scientific = FALSE),
                    PORT_JOIN = PORT_JOIN %>%
                      format(scientific = FALSE),
                    CRUISE = CRUISE %>%
                      format(scientific = FALSE)) -> lfreq_data_generic_V2

# LEFT OFF HERE 11/4/24 10:43: DO NOT CONTINUE WITH SPECIES 202 BECAUSE I ALREADY HAVE CODE FOR IT IN baseISS. MOVE ON TO ANOTHER SPECIES.



tictoc::tic()
fishery_iss(species_code = "202", # called "SPECIES" in non_generic and "SPECIES_KEY" in generic
            area_code = "EBS", # called "AREA2" curated from "NMFS_AREA" and "FMP_AREA".
            length_based = TRUE,
            iters = 1,
            freq_data = lfreq_data_generic,
            yrs = 1999,
            post_strata = list(strata = c("GEAR"), nested = FALSE),
            minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30),
            new_length_N = list(type = "value", bound = NULL, amount = 20),
            max_length = "data_derived",
            boot.trip = TRUE,
            boot.haul = TRUE,
            boot.length = TRUE,
            boot.age = FALSE,
            expand.by.sampling.strata = TRUE,
            expansion_factors = c("haul_numbers", "month_numbers"),
            save_args = TRUE) -> .output
tictoc::toc()
.output


saveRDS(.output, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/", run_name, "_ISS_", iterations, "iters_output_", Sys.Date(), ".RDS"))




















