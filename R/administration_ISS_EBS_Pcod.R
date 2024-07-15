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

boot_trips(og_lf_data) -> .lf_data

# .lf_data %>% # I need to make a subsetted og_lf_data DT with only the "trips" that have been resampled.
#   tidytable::left_join(og_lf_data) -> temp


# take a different route. just return a DT of years, resampled_cruise, and associated HAUL_JOIN. Use this as input to boot_haul.
.lf_data[,.N, by = .(YEAR, CRUISE)] -> temp

.lf_data %>%
  tidytable::mutate(HAUL_JOIN = CRUISE, by = YEAR)

tidytable::select(YEAR, CRUISE)




















