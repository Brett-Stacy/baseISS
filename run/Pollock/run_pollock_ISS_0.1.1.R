# Pollock

# test improved SQL download that converts things to characters for:
# debriefed_length_mv (length data and strata),
# debriefed_haul_mv (trip_seq for creating accurate trip_join). Note that the TRIP_JOIN in debriefed_haul_mv should NOT be used for trip_join in the ISS analysis. Therefore it should not be part of the .sql download.
# debriefed_spcomp_mv (for extrapolated_numbers for expand.by.sampling.strata). extrapolated_weight can also be retrieved from debriefed_spcomp_mv


rm(list = ls())
run_name = "generic_201_V3"
iterations = 100


lfreq_data_201 = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/species_201_generic_V2.RDS")
spcomp_data_201 = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/spcomp_generic_201_V2.RDS")
haul_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/haul_generic_201.RDS")


library(tidytable)
library(baseISS)


lfreq_data_201 %>%
  glimpse()

##### Standard Processing Steps ----

# Filter out SEX for now and remove NAs for LENGTH and HAUL_JOIN
lfreq_data_201 %>%
  tidytable::mutate(SEX_KEY = NULL, SEX = NULL) %>%
  tidytable::drop_na(LENGTH, HAUL_JOIN) -> lfreq_data_201_V2

# Join with haul_mv to get trip join and spcomp_mv to get extrapolated numbers, also rename this to YAGMH_SNUM
lfreq_data_201_V2 %>%
  tidytable::left_join(haul_data) %>%
  tidytable::mutate(TRIP_JOIN = paste(CRUISE, PERMIT, TRIP_SEQ, sep = "-")) %>%
  tidytable::left_join(spcomp_data_201) -> lfreq_data_201_V3
# tidytable::rename(YAGMH_SNUM = EXTRAPOLATED_NUMBER)


lfreq_data_201_V3 %>%
  glimpse()




tictoc::tic()
fishery_iss(species_code = "201",
            area_code = "unknown",
            length_based = TRUE,
            iters = iterations,
            freq_data = lfreq_data_201_V3,
            yrs = 1999,
            bin = NULL,
            plus_len = NULL,
            post_strata = NULL,
            minimum_sample_size = NULL,
            new_trip_N = NULL,
            new_haul_N = NULL,
            new_length_N = NULL,
            max_length = "data_derived",
            boot.trip = TRUE,
            boot.haul = TRUE,
            boot.length = TRUE,
            boot.age = FALSE,
            expand.by.sampling.strata = TRUE,
            expansion_factors = NULL,
            save_data_frame = TRUE) -> .output
tictoc::toc()
.output


saveRDS(.output, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/Pollock/", run_name, "_ISS_", iterations, "iters_output_", Sys.Date(), ".RDS"))
















