# 201

# test improved SQL download that converts things to characters for:
# debriefed_length_mv (length data and strata),
# debriefed_haul_mv (trip_seq for creating accurate trip_join),
# debriefed_spcomp_mv (for extrapolated_numbers for expand.by.sampling.strata)

# Ignore port_join I guess. Steve does some processing in R to join the ports and calculate YAGM_SNUM and I assume YAGMH_SNUM. He would
# have to because this is required for WEIGHT1. I simply cannot do this for an alternate species, so ignore port_join for now.


#### GET RID OF PORT JOIN!!



rm(list = ls())
run_name = "generic_201_V3"
iterations = 1

lfreq_data_201 = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/species_201_generic_V2.RDS")
spcomp_data_201 = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/spcomp_generic_201_V2.RDS")
haul_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/haul_generic_201.RDS")


library(tidytable)
library(baseISS)


# Explore differences in curated vs generic data sets
# lfreq_data_non_generic %>%
  # glimpse()

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


##### END: Standard Processing Steps


tictoc::tic()
fishery_iss(species_code = "201", # called "SPECIES" in non_generic and "SPECIES_KEY" in generic
            area_code = "unknown",
            length_based = TRUE,
            iters = 1,
            freq_data = lfreq_data_201_V3,
            yrs = 1999,
            post_strata = NULL,
            minimum_sample_size = NULL, # list(resolution = "FREQUENCY", size = 1),
            new_length_N = list(type = "value", bound = NULL, amount = 20),
            max_length = "data_derived",
            boot.trip = TRUE,
            boot.haul = TRUE,
            boot.length = TRUE,
            boot.age = FALSE,
            expand.by.sampling.strata = TRUE, # change this when fix above spcomp issue
            expansion_factors = NULL) -> .output # c("haul_numbers", "month_numbers"),
tictoc::toc()
.output


saveRDS(.output, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/", run_name, "_ISS_", iterations, "iters_output_", Sys.Date(), ".RDS"))




















