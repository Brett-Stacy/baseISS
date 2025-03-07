# Pollock

# Test generic species data download function and run fishery_iss().

rm(list = ls())
run_name = "generic_201_0.2.1"
iterations = 1
species = 201



library(tidytable)
library(baseISS)


##### Download Data ----
lfreq_data_201 = download_akfin_data(akfin_credentials = list(uid="bstacy",pwd="Dasmanid78."),
                                     species_code = species,
                                     composition_type = "LENGTH",
                                     save_file_path = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/Pollock/generic_201_0.2.1.RDS")


##### Processing Steps ----

# Remove sex and migrate port_join to haul_join where haul_join=NA.

lfreq_data_201 %>%
  tidytable::filter(is.na(HAUL_JOIN)) %>%
  tidytable::mutate(HAUL_JOIN = PORT_JOIN) %>%
  tidytable::bind_rows(lfreq_data_201 %>%
                         tidytable::filter(!is.na(HAUL_JOIN))) %>%
  tidytable::mutate(SEX_KEY = NULL, SEX = NULL) -> lfreq_data_201_v2





tictoc::tic()
fishery_iss(species_code = species,
            area_code = "unknown",
            length_based = TRUE,
            iters = iterations,
            freq_data = lfreq_data_201_v2,
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
















