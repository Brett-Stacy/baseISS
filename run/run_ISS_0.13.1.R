# Generic 201 -pollock species key download capability.

rm(list = ls())
run_name = "generic_201_V1"
iterations = 1

# lfreq_data_non_generic = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP_STRATA.RDS")
lfreq_data_generic = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/species_201_generic.RDS")
library(tidytable)
library(baseISS)


# Explore differences in curated vs generic data sets
# lfreq_data_non_generic %>%
  # glimpse()

lfreq_data_generic %>%
  glimpse()

##### Standard Processing Steps ----

# no sex for now
lfreq_data_generic$SEX = NULL

# some things need to be characters instead of numeric. TEMPORARY SOLUTION BECAUSE THE CHARACTER STRINGS THAT GET CREATED HAVE BIG BLANK GAPS. PROBABLY NEED TO ADJUST THE SQL TO CONVERT TO CHARACTER WHEN DOWNLOADED.
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

# remove LENGTH=NA
lfreq_data_generic_V2 %>%
  tidytable::drop_na(LENGTH) -> lfreq_data_generic_V3

# add TRIP_JOIN. TEMPORARY SOLUTION, NEED TO ADD TRIP_SEQ BACK IN WHEN DOWNLOAD IT WITH SQL
lfreq_data_generic_V3 %>%
  tidytable::mutate(TRIP_JOIN = paste(CRUISE, PERMIT, sep = "-")) -> lfreq_data_generic_V4 # paste(CRUISE, PERMIT, TRIP_SEQ, sep = "-"))




# join with spcomp to get extrapoleted_numbers to turn into YAGMH_SNUM for expand_by_sampling_strata
spcomp_data_201 = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/spcomp_generic_201.RDS")

spcomp_data_201 %>%
  glimpse()

# spcomp_data_201 %>%
#   tidytable::select(YEAR, JOIN_KEY, EXTRAPOLATED_NUMBER) %>%
#   tidytable::mutate(JOIN_KEY = JOIN_KEY %>%
#                       format(scientific = FALSE)) %>%
#   tidytable::drop_na() %>%
#   tidytable::distinct() -> spcomp_data_201_V2

spcomp_data_201 %>%
  tidytable::select(YEAR, HAUL_JOIN, EXTRAPOLATED_NUMBER) %>%
  tidytable::mutate(HAUL_JOIN = HAUL_JOIN %>%
                      format(scientific = FALSE)) %>%
  tidytable::drop_na() %>%
  tidytable::distinct(HAUL_JOIN, .keep_all = TRUE) -> spcomp_data_201_V2

spcomp_data_201_V2 %>%
  glimpse()

lfreq_data_generic_V4 %>%
  tidytable::left_join(spcomp_data_201_V2) -> lfreq_data_generic_V5 # FIXED: joining by distinct haul_join fixed the issue: # major issue: takes forever and too big of an object results


lfreq_data_generic_V5 %>%
  tidytable::glimpse()

##### END: Standard Processing Steps


tictoc::tic()
fishery_iss(species_code = "201", # called "SPECIES" in non_generic and "SPECIES_KEY" in generic
            area_code = "unknown",
            length_based = TRUE,
            iters = 1,
            freq_data = lfreq_data_generic_V4,
            yrs = 1999,
            post_strata = NULL,
            minimum_sample_size = NULL, # list(resolution = "FREQUENCY", size = 1),
            new_length_N = NULL, # list(type = "value", bound = NULL, amount = 20),
            max_length = "data_derived", # data_derived did not work for some reason
            boot.trip = TRUE,
            boot.haul = TRUE,
            boot.length = TRUE,
            boot.age = FALSE,
            expand.by.sampling.strata = FALSE, # change this when fix above spcomp issue
            expansion_factors = NULL, # c("haul_numbers", "month_numbers"),
            save_args = TRUE) -> .output
tictoc::toc()
.output


saveRDS(.output, file = paste0("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/outputs/", run_name, "_ISS_", iterations, "iters_output_", Sys.Date(), ".RDS"))




















