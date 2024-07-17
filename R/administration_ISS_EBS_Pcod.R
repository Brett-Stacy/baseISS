# Script for administrating ISS for EBS Pcod
# Start this off as a script for running functions in the baseISS package, then eventually turn it into a function.




# Load in necessary EBS Pcod data
og_lf_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/y2_ebs_pcod_Brett.RDS")
# Need a data table with lengths and weightings.

# for reference:
colnames(og_lf_data) #  "SPECIES"       "YEAR"          "AREA2"         "GEAR"          "MONTH"         "CRUISE"        "VES_AKR_ADFG"  "HAUL_JOIN"     "LENGTH"        "YAGMH_STONS"   "YAGMH_SNUM"
# "SUM_FREQUENCY" "YAGMH_SFREQ"   "YAGM_STONS"    "YAGM_SNUM"     "YAGM_SFREQ"    "YAG_STONS"     "YAG_SNUM"      "YAG_SFREQ"     "YG_STONS"      "YG_SNUM"       "YG_SFREQ"
# "Y_STONS"       "Y_SNUM"        "Y_SFREQ"       "YAGM_TONS"     "YAGM_TNUM"     "YAG_TONS"      "YAG_TNUM"      "YG_TONS"       "YG_TNUM"       "Y_TONS"        "Y_TNUM"
# "WEIGHT1"       "WEIGHT2"       "WEIGHT3"       "WEIGHT4"







# ----
# Calculate og proportions-at-length

og_l_props = expand_length_props(og_lf_data)



# ----
# Boot the stuff: Trip, Haul, Lengths
# execute boot_ functions here.


# Boot trips (CRUISE for now)
boot_trip(og_lf_data) -> .r_trips # resampled trips




# Get a DT of YEAR, resampled CRUISE, and associated HAUL_JOIN. Use this as input to boot_haul.
# .r_trips[,.N, by = .(YEAR, CRUISE)] # just taking a look at the number of repeated resampled CRUISE



og_lf_data[, unique(HAUL_JOIN), by = .(YEAR, CRUISE)] %>% # turn og data into a tidytable and condense to the unique YEAR, CRUISE, HAUL_JOIN
  tidytable::tidytable() %>%
  rename(HAUL_JOIN = V1) -> .unique_hauls


.unique_hauls %>% # gives only resampled trips and associated hauls. Hauls are repeated if resampled trips are repeated. ready for boot_haul.
  right_join(.r_trips) -> .joined_trips



# Boot hauls
boot_haul(.joined_trips) %>%
  tidytable::mutate(hauljoin_unique = .I)-> .r_hauls # resampled hauls

# .r_hauls %>%
  # count(HAUL_JOIN)


# Get a DT that looks like og_lf_data but consists only of .r_hauls.
og_lf_data %>%
  right_join(.r_hauls) -> .joined_hauls
# .joined_hauls[YEAR==1991 & HAUL_JOIN=="H320751"] %>% print(n=500) # this looks like what I wanted. Use hauljoin_unique in boot_length as it is the unique identifier for the resampled HAUL_JOIN (which some are repeated so require a unique identifier)
# .joined_hauls[YEAR==1991, unique(HAUL_JOIN)] %>% length()





# Boot lengths
boot_length(.joined_hauls) -> .joined_lengths




# Expand bootstrapped population
boot1_l_props = expand_length_props(.joined_lengths)















