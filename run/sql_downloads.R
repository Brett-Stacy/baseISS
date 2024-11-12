


# Need to connect to AKFIN with username and passoword using C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/odbc_login.R to run below code.

library(dplyr)

## Functions ----

sql_run <- function(database, query) {
  query = paste(query, collapse = "\n")
  DBI::dbGetQuery(database, query, as.is=TRUE, believeNRows=FALSE)
}





#### Incorporate observer trip into y2 object ----
# import some data from SQL Developer for trip_join
# from ebs pcod:
# lfreq = readLines('C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/test.sql') # test.sql is a data frame of just haul_join and trip_join for ALL the observer data
#
#
# sql_run <- function(database, query) {
#   query = paste(query, collapse = "\n")
#   DBI::dbGetQuery(database, query, as.is=TRUE, believeNRows=FALSE)
# }
#
#
# temp=sql_run(akfin, lfreq)
# joinDT = data.table::setDT(temp)
#
# # join it with the input data frame for baseISS
# lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/y2_ebs_pcod_Brett.RDS")
#
# new_lfreq_data = tidytable::left_join(lfreq_data, joinDT)
# # well that din't work because there are a bunch of trip_join values that are just "T"


#### Take 2, manual trip join ----
# let's try to make a unique trip join identifier using Jen's suggested combination of Cruise, Permit, and trip_seq
lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_ebs_pcod_Brett.RDS")
lfreq2 = readLines('C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS/sql_files/test2.sql') # test2.sql includes Cruise, Permit, and trip_seq

temp2=sql_run(akfin, lfreq2)
joinDT2 = data.table::setDT(temp2)

joinDT2 %>%
  tidytable::mutate(TRIP_JOIN = paste(CRUISE, PERMIT, TRIP_SEQ, sep = "-")) %>%
  tidytable::select(YEAR, HAUL_JOIN, TRIP_JOIN) -> .joinDT2 # there are NAs in TRIP_SEQ so they show up in this joined ID but it's still better than the TRIP_JOIN that comes with the data download

# join it with the input data frame for baseISS
new_lfreq_data2 = tidytable::left_join(lfreq_data, .joinDT2) # this looks better

# save the new data table with TRIP_JOIN added
saveRDS(new_lfreq_data2, file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_ebs_pcod_Brett_TRIP.RDS")










#### Incorporate sampling strata column ----
# for use in bootstrapping within strata
lfreq_data_trip = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_ebs_pcod_Brett_TRIP.RDS")
sampling_strata = readLines('C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS/sql_files/sampling_strata.sql') # includes haul_join and sampling_strata

temp_sampling_strata = sql_run(akfin, sampling_strata)
joinDT_temp = data.table::setDT(temp_sampling_strata)

# join it with the input data frame for baseISS
new_lfreq_data3 = tidytable::left_join(lfreq_data_trip, joinDT_temp)

# save the new data table with SAMPLING_STRATA_... added
saveRDS(new_lfreq_data3, file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_ebs_pcod_Brett_TRIP_STRATA2.RDS") # this is 2 because for the first one, I forgot to rename lfreq_data to lfreq_data_trip in the left_join.


# play with it
new_lfreq_data3[,.N, by=.(SAMPLING_STRATA_NAME, YEAR)] %>% print(n=100)











#### Steve's EBS Pcod 2023 y2 object combined sex - add trip join ----

lfreq_data_steve = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve.RDS")
# inspect this a bit
lfreq_data_steve[, unique(YEAR)] # years in the data 1977-2023
lfreq_data_steve[,.N, by = .(YEAR, HAUL_JOIN)][,.N, by = .(YEAR)] # number of unique hauls every year
# According to this line of SQL code in dom_length_port_C.sql: concat('P', TO_CHAR(obsint.debriefed_length.port_join)) AS haul_join,
# there is a "port_join" column that is turned into "haul_join", designated with a "P" prefix.


lfreq_data_steve %>%
  tidytable::tidytable() %>%
  tidytable::mutate(join_prefix = substr(HAUL_JOIN, 1, 1)) -> .temp # new column of prefix P or H

.temp %>% # how many Ps and Hs are there?
  tidytable::count(join_prefix)

.temp %>% # were there Ps and Hs every year?
  tidytable::summarise(, .by = c(YEAR, join_prefix)) %>%
  print(n=80)

.temp %>% # were there Ps and Hs every year?
  tidytable::summarise(sum(join_prefix=="P"), .by = YEAR) %>%
  print(n=50)

.temp[join_prefix=="P",] %>% # there are like 200 observations per port_join here. This means port_join represents a delivery right?
  print(n=200)
.temp[join_prefix=="P", summary(YAGMH_SFREQ)] # median is 120
.temp[join_prefix=="P", unique(YAGMH_SFREQ)] %>% hist()




lfreq2.2 = readLines('C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS/sql_files/test2.sql')

temp2.2=sql_run(akfin, lfreq2.2)
saveRDS(temp2.2, "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/temp2.2_trip_V1_sql_download.RDS")


joinDT2.2 = data.table::setDT(temp2.2)

joinDT2.2 %>%
  tidytable::mutate(TRIP_JOIN = paste(CRUISE, PERMIT, TRIP_SEQ, sep = "-")) %>%
  tidytable::select(YEAR, HAUL_JOIN, TRIP_JOIN) -> .joinDT2.2



# join it with the input data frame for baseISS
new_lfreq_data2 = tidytable::left_join(lfreq_data_steve, .joinDT2.2) # this will join TRIP_JOIN to Steve's y2 data by YEAR and HAUL_JOIN. There will be NAs for TRIP_JOIN where Steve's data does not have a match for YEAR and HAUL_JOIN, i.e., for port data and most foreign data. For port data, there won't be a match because the HAUL_JOINs start with "P". For foreign data, there will only be a few YEARs that match.

# look at what happened to trip_join for PORT DATA
new_lfreq_data2 %>%
  tidytable::summarise(length(unique(TRIP_JOIN)), .by = YEAR) %>%
  print(n = 100)

new_lfreq_data2[YEAR==1986, .N, by = .(TRIP_JOIN, HAUL_JOIN)]

new_lfreq_data2 %>% # port samples start in 1990
  tidytable::summarise(unique(substr(HAUL_JOIN, 1, 1)), .by = YEAR) %>%
  print(n = 100)

new_lfreq_data2[substr(HAUL_JOIN, 1, 1)=="P",] %>% # confirms there are NAs for all port data for TRIP_JOIN
  tidytable::summarise(unique(TRIP_JOIN), .by = YEAR) %>%
  print(n = 100)

## Transfer haul_join to trip_join. Do this only for port ("P" prefix) data to avoid doing it for foreign data as well as port.
# new_lfreq_data2.2 = new_lfreq_data2
# new_lfreq_data2.2[substr(HAUL_JOIN, 1, 1)=="P", TRIP_JOIN := HAUL_JOIN] # this doesn't work appropriately. It replaces values in new_lfreq_data2 as well as 2.2!!! BAD

# test a different suffix
# new_lfreq_data2_test = new_lfreq_data2
# new_lfreq_data2_test[substr(HAUL_JOIN, 1, 1)=="P", TRIP_JOIN := HAUL_JOIN]

# try a different way
new_lfreq_data2.2 = new_lfreq_data2 %>%
  # tidytable::mutate(TRIP_JOIN = base::replace(TRIP_JOIN, base::substr(HAUL_JOIN, 1, 1)=="P", HAUL_JOIN)) # intent: replace trip join with haul join where haul join has "P" prefix.
  # tidytable::mutate(TRIP_JOIN = base::replace(TRIP_JOIN, base::substr(HAUL_JOIN, 1, 1)=="P", HAUL_JOIN[base::substr(HAUL_JOIN, 1, 1)=="P"])) # this works but is convoluted
  # tidytable::mutate(TRIP_JOIN = base::replace(TRIP_JOIN, base::substr(HAUL_JOIN, 1, 1)=="P", HAUL_JOIN[base::substr(new_lfreq_data2.2$HAUL_JOIN, 1, 1)=="P"])) # this works but is more convoluted
  tidytable::mutate(TRIP_JOIN = base::ifelse(base::substr(HAUL_JOIN, 1, 1)=="P", HAUL_JOIN, TRIP_JOIN)) # this works and is clear



# check
new_lfreq_data2[YEAR==1990, unique(TRIP_JOIN)] # should be NAs
new_lfreq_data2.2[YEAR==1990, unique(TRIP_JOIN)] # should be no more NAs, replaced with haul join

# test a different suffix
# new_lfreq_data2_test[YEAR==1989, unique(TRIP_JOIN)]


## Foreign onboard observer trip 1977-1990
# For now, call NA foreign trip_joins CRUISE. Then update when I get the trip data somehow.
new_lfreq_data2.2 %>%
  tidytable::summarise(length(unique(TRIP_JOIN)), .by = YEAR) %>%
  print(n = 100)


# new_lfreq_data2.3 = new_lfreq_data2.2
# new_lfreq_data2.3[is.na(TRIP_JOIN), TRIP_JOIN := CRUISE] # the remainder trip_joins are NA and they represent the foreign data, so pick these out and call them year x cruise.

# test a different suffix
# new_lfreq_data2_test_again = new_lfreq_data2_test
# new_lfreq_data2_test_again[is.na(TRIP_JOIN), TRIP_JOIN := CRUISE] # the remainder trip_joins are NA and they represent the foreign data, so pick these out and call them year x cruise.
# wtf? it appears that := changes every object equal to the one being worked on! even with a different suffix (expected result)

# try a different way for this too
new_lfreq_data2.3 = new_lfreq_data2.2 %>%
  tidytable::mutate(TRIP_JOIN = base::ifelse(base::is.na(TRIP_JOIN), CRUISE, TRIP_JOIN))


# check
sum(is.na(new_lfreq_data2.3$TRIP_JOIN))
new_lfreq_data2.3[1:10, TRIP_JOIN]

new_lfreq_data2.2[YEAR==1989, unique(TRIP_JOIN)] # should be NAs
new_lfreq_data2.3[YEAR==1989, unique(TRIP_JOIN)] # should be no more NAs, replaced with cruise

new_lfreq_data2.3[YEAR==1980, unique(TRIP_JOIN)] # should be no more NAs, replaced with cruise

# everything checks out as at 8/7/24

# save the new data table with TRIP_JOIN added
saveRDS(new_lfreq_data2.3, file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP.RDS")















#### Steve's EBS Pcod 2023 y2 object combined sex - add strata join ----
# REMEMBER: FOR THIS I WILL NEED TO MATCH UP "HAUL_JOIN" FROM THE PORT DATA WITH THAT FROM THE STRATA.SQL DOWNLOAD. THIS WILL NEED TO CONSIDER THE "P" PREFIX. Probably make a new .sql file that does not concat H or P, but

lfreq_data_trip2 = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP.RDS")
sampling_strata = readLines('C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS/sql_files/sampling_strata2.sql') # includes haul_join port_join and sampling_strata

# temp_sampling_strata = sql_run(akfin, sampling_strata)
# saveRDS(temp_sampling_strata, "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/sampling_strata2_V1_sql_download.RDS")
temp_sampling_strata = readRDS("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/sampling_strata2_V1_sql_download.RDS")

joinDT_temp = data.table::setDT(temp_sampling_strata)

# match the port_joins
# lfreq_data_trip2 %>%
#   tidytable::summarise(HAUL_JOIN = unique(HAUL_JOIN)) %>%
#   tidytable::filter(base::substr(HAUL_JOIN, 1, 1)=="P") %>%
#   tidytable::mutate(PORT_JOIN = base::substr(HAUL_JOIN, 2, base::nchar(HAUL_JOIN))) %>%
#   tidytable::select(PORT_JOIN) %>%
#   tidytable::left_join(joinDT_temp) -> temp
#
# sum(!is.na(temp$SAMPLING_STRATA_NAME)) # some not NAs - good
# sum(!is.na(temp$HAUL_JOIN)) # all NAs - good
# temp[!is.na(SAMPLING_STRATA_NAME), unique(SAMPLING_STRATA_NAME)] # some names in here

# port strata join
lfreq_data_trip2 %>%
  tidytable::mutate(PORT_JOIN = base::ifelse(base::substr(HAUL_JOIN, 1, 1)=="P", HAUL_JOIN, NA)) %>% # make a temporary column for port join where haul join starts with "P". These were originally port joins before being renamed haul joins in the sql download
  tidytable::mutate(PORT_JOIN = base::substr(PORT_JOIN, 2, base::nchar(PORT_JOIN))) %>% # substr to match sql download
  tidytable::left_join(joinDT_temp %>%
                         tidytable::select(-HAUL_JOIN) %>%
                         tidytable::drop_na(PORT_JOIN) %>%
                         tidytable::distinct(PORT_JOIN, .keep_all = TRUE)) -> temp_P # this now includes the strata information for port data, now I need to add the strata information for onboard data

# haul strata join
lfreq_data_trip2 %>%
  tidytable:: mutate(TEMP_HAUL_JOIN = base::ifelse(base::substr(HAUL_JOIN, 1, 1)=="H", HAUL_JOIN, NA)) %>% # make temporary haul join column where it is only not an NA when prefix "H" is present. This will isolate the non-port observations
  tidytable::mutate(TEMP_HAUL_JOIN = base::substr(HAUL_JOIN, 2, base::nchar(HAUL_JOIN))) %>%
  tidytable::left_join(joinDT_temp %>%
                         tidytable::select(-PORT_JOIN) %>%
                         tidytable::drop_na(HAUL_JOIN) %>%
                         tidytable::distinct(HAUL_JOIN, .keep_all = TRUE) %>%
                         tidytable::mutate(TEMP_HAUL_JOIN = HAUL_JOIN) %>%
                         tidytable::select(-HAUL_JOIN)) -> temp_H

# good.names = c("SAMPLING_STRATA", "SAMPLING_STRATA_NAME", "SAMPLING_STRATA_DEPLOYMENT_CATEGORY", "SAMPLING_STRATA_SELECTION_RATE")

# combine
temp_combine = tidytable::select(temp_H, -TEMP_HAUL_JOIN)
temp_combine[base::substr(HAUL_JOIN, 1, 1)=="P", c("SAMPLING_STRATA", "SAMPLING_STRATA_NAME", "SAMPLING_STRATA_DEPLOYMENT_CATEGORY", "SAMPLING_STRATA_SELECTION_RATE")] =
  temp_P[base::substr(HAUL_JOIN, 1, 1)=="P", c("SAMPLING_STRATA", "SAMPLING_STRATA_NAME", "SAMPLING_STRATA_DEPLOYMENT_CATEGORY", "SAMPLING_STRATA_SELECTION_RATE")]





# lfreq_data_trip2 %>%
#   tidytable::mutate(PORT_JOIN = base::ifelse(base::substr(HAUL_JOIN, 1, 1)=="P", HAUL_JOIN, NA)) %>% # make a temporary column for port join where haul join starts with "P". These were originally port joins before being renamed haul joins in the sql download
#   tidytable::mutate(PORT_JOIN = base::substr(PORT_JOIN, 2, base::nchar(PORT_JOIN))) %>% # substr to match sql download
#   tidytable::mutate(TEMP_HAUL_JOIN = base::ifelse(base::substr(HAUL_JOIN, 1, 1)=="H", HAUL_JOIN, NA)) %>% # make temporary haul join column where it is only not an NA when prefix "H" is present. This will isolate the non-port observations
#   tidytable::mutate(TEMP_HAUL_JOIN = base::substr(HAUL_JOIN, 2, base::nchar(HAUL_JOIN))) %>%
#   tidytable::left_join(joinDT_temp %>%
#                          tidytable::distinct(PORT_JOIN, HAUL_JOIN, .keep_all = TRUE) %>%
#                          tidytable::mutate(TEMP_HAUL_JOIN = HAUL_JOIN) %>%
#                          tidytable::select(-HAUL_JOIN)) -> temp_PH

  # tidytable::select(-PORT_JOIN, -TEMP_HAUL_JOIN) -> new_lfreq_data3.2

# inspect

temp_P[!is.na(SAMPLING_STRATA_NAME), unique(SAMPLING_STRATA_NAME)]
temp_H[!is.na(SAMPLING_STRATA_NAME), unique(SAMPLING_STRATA_NAME)]
# temp_PH[!is.na(SAMPLING_STRATA_NAME), unique(SAMPLING_STRATA_NAME)]
# temp[!is.na(PORT_JOIN), unique(SAMPLING_STRATA_NAME)]
temp_combine[!is.na(SAMPLING_STRATA_NAME), unique(SAMPLING_STRATA_NAME)] # looks good finally

# for baseISS
new_lfreq_data3.2 = temp_combine

# save the new data table with SAMPLING_STRATA_... added
saveRDS(new_lfreq_data3.2, file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP_STRATA.RDS")


# play with it
new_lfreq_data3.2[,.N, by=.(SAMPLING_STRATA_NAME, YEAR)] %>% print(n=100) # well, for some reason there are NAs in 2023. Not sure why.

new_lfreq_data3.2[YEAR==2023,.N, by=.(SAMPLING_STRATA_NAME)] %>% print(n=100)

new_lfreq_data3.2[YEAR==2023 & is.na(SAMPLING_STRATA_NAME), c(8, 38:42)] %>% print(n=100) # they are haul joins


new_lfreq_data3.2[YEAR==2010,.N, by=.(SAMPLING_STRATA_NAME)] %>% print(n=100) # and in 2010
new_lfreq_data3.2[YEAR==2010 & is.na(SAMPLING_STRATA_NAME), c(8, 38:42)] %>% print(n=100) # but this makes a little more sense because they are port joins.













#### Steve's EBS Pcod 2023 y2 object separate sex - join to above ----
new_lfreq_data3.2 = readRDS("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP_STRATA.RDS")

lfreq_data_steve_sex = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_sex_ebs_pcod_Steve.RDS") %>%
  tidytable::as_tidytable()

lfreq_data_steve_sex[, .N, by = SEX]

new_lfreq_data3.2[, n_distinct(HAUL_JOIN)]
lfreq_data_steve_sex[, n_distinct(HAUL_JOIN)]

lfreq_data_steve_sex %>%
  tidytable::left_join(new_lfreq_data3.2 %>%
                         tidytable::select(YEAR, HAUL_JOIN, TRIP_JOIN, SAMPLING_STRATA, SAMPLING_STRATA_NAME, SAMPLING_STRATA_DEPLOYMENT_CATEGORY, SAMPLING_STRATA_SELECTION_RATE) %>%
                         tidytable::distinct())  -> new_lfreq_data3.3 # OK this works now

unique(new_lfreq_data3.2$TRIP_JOIN)
unique(new_lfreq_data3.3$TRIP_JOIN) # this is bad!!! FIX THIS! SOMETHING WENT WRONG WITH LEFT_JOIN ABOVE. I FIXED IT using the above select and distinct code.
glimpse(new_lfreq_data3.2)
glimpse(lfreq_data_steve_sex)
glimpse(new_lfreq_data3.3)
# identical(lfreq_data_steve_sex,
#           new_lfreq_data3.3 %>%
#             tidytable::select(-c(TRIP_JOIN, SAMPLING_STRATA, SAMPLING_STRATA_NAME, SAMPLING_STRATA_DEPLOYMENT_CATEGORY, SAMPLING_STRATA_SELECTION_RATE)))
identical(unique(new_lfreq_data3.2$TRIP_JOIN), unique(new_lfreq_data3.3$TRIP_JOIN))


# save the new data table with sex added
saveRDS(new_lfreq_data3.3, file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_sex_ebs_pcod_Steve_TRIP_STRATA.RDS")



















#### Age V1

# read in the latest data join
new_lfreq_data3.3 = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_sex_ebs_pcod_Steve_TRIP_STRATA.RDS")
# age_data = readLines('C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS/sql_files/age1.sql')
# temp_age = sql_run(akfin, age_data)
# saveRDS(temp_age, "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/age_data_V1_sql_download.RDS")
temp_age = readRDS("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/age_data_V1_sql_download.RDS") %>%
  tidytable::as_tidytable()


### try downloading the data by species because I can't get haul_joins to match with y2 object and maybe that's why?
# age_data2 = readLines('C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS/sql_files/age2.sql')
# temp_age2 = sql_run(akfin, age_data2)
# saveRDS(temp_age2, "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/age_data_V2_sql_download.RDS")
temp_age = readRDS("C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/age_data_V2_sql_download.RDS") %>%
  tidytable::as_tidytable()




# convert stuff to character to later join it
# options(scipen=999)
# temp_age %>% tidytable::mutate(HAUL_JOIN = as.character(HAUL_JOIN),
                               # PORT_JOIN = as.character(PORT_JOIN)) -> temp_age


# Inspect the haul_join prefixes because I will need to merge the age data using haul_join
new_lfreq_data3.3 %>%
  tidytable::tidytable() %>%
  tidytable::mutate(join_prefix = substr(HAUL_JOIN, 1, 1)) -> .temp # new column of prefix P or H

.temp %>% # how many Ps and Hs are there?
  tidytable::count(join_prefix)

# find out if these haul_joins are unique without their prefixes. I hope they are.
new_lfreq_data3.3[, n_distinct(HAUL_JOIN)]
new_lfreq_data3.3[, n_distinct(substr(HAUL_JOIN, 2, base::nchar(HAUL_JOIN)))]
# uh-oh, there are 200 mismatch




########## for now, just go with the information that matches the age data. Join by haul_join without any prefix

# check common columns
names(new_lfreq_data3.3)[names(new_lfreq_data3.3) %in% names(temp_age)]

# check if any hauls match up
# new_lfreq_data3.3[YEAR==2023, substr(unique(HAUL_JOIN), 2, nchar(HAUL_JOIN))]
# temp_age[YEAR==2023, unique(HAUL_JOIN)]

# new_lfreq_data3.3[YEAR==2023, substr(unique(HAUL_JOIN), 2, nchar(HAUL_JOIN))] %in%
# temp_age[YEAR==2023, unique(HAUL_JOIN)] %>% sum()
new_lfreq_data3.3[YEAR==2023, unique(HAUL_JOIN)] %in%
  temp_age[YEAR==2023, unique(HAUL_JOIN)] %>% sum()

# new_lfreq_data3.3[YEAR==2023, substr(unique(HAUL_JOIN), 2, nchar(HAUL_JOIN))][1:10]
# temp_age[YEAR==2023, unique(HAUL_JOIN)][1:10]





### join
# This will join the age data with the hauls from which length data was used.

# new_lfreq_data3.3 %>%
#   tidytable::distinct(HAUL_JOIN, .keep_all = TRUE) %>% # only keep data pertaining to unique haul_join values
#   tidytable::select(-c(LENGTH, SUM_FREQUENCY, WEIGHT1, YAGMH_SFREQ, YAGM_SFREQ, YAG_SFREQ, YG_SFREQ, Y_SFREQ, SEX)) %>% # get rid of columns only applicable to length data
#   tidytable::right_join(temp_age %>%
#                           tidytable::select(YEAR, SPECIES, HAUL_JOIN, PORT_JOIN, SEX, LENGTH, AGE) %>%
#                           tidytable::drop_na(AGE, LENGTH, SEX) %>%
#                           tidytable::mutate(HAUL_JOIN = base::ifelse(base::is.na(HAUL_JOIN), base::paste0("P", PORT_JOIN), base::paste0("H", HAUL_JOIN))) %>%
#                           tidytable::select(-PORT_JOIN)) -> temp_combined
#   tidytable::drop_na(TRIP_JOIN)
# temp_combined %>% glimpse()

# with V2
new_lfreq_data3.3 %>%
  tidytable::distinct(HAUL_JOIN, .keep_all = TRUE) %>% # only keep rows pertaining to unique haul_join values
  tidytable::select(-c(LENGTH, SUM_FREQUENCY, WEIGHT1, YAGMH_SFREQ, YAGM_SFREQ, YAG_SFREQ, YG_SFREQ, Y_SFREQ, SEX)) %>% # get rid of columns only applicable to length data
  tidytable::left_join(temp_age %>% # join with age. Even thought there is only one row per unique haul_join, this join will expand each unique row by the number of age observations in the corresponding age data frame.
                          tidytable::select(YEAR, HAUL_JOIN, SEX, LENGTH, AGE) %>% # Only keep the necessary columns.
                          tidytable::drop_na(AGE, LENGTH, SEX)) %>% # many NAs for age for some reason
tidytable::drop_na(AGE) -> new_afreq_data1.0
new_afreq_data1.0 %>% glimpse()


# check stuff - looks good
sort(unique(new_lfreq_data3.3$YEAR))
sort(unique(temp_age$YEAR))
sort(unique(new_afreq_data1.0$YEAR))
sort(unique(new_afreq_data1.0$SAMPLING_STRATA_NAME))
sort(unique(new_afreq_data1.0$AGE)) # no 17 year olds I guess


# recalculate necessaries - sum_frequency (for weight1), yagmh_sfreq (for weight1), yagm_sfreq (for >30 filter)
# wait, perhaps not because I have and need length in there. Sum_frequency would only be for age, then what would happen to lengths? Hold off on this for now.
new_afreq_data1.0 %>%
  tidytable::summarise(SUM_FREQUENCY = n(base::unique(AGE)), .by = c(YEAR, HAUL_JOIN, AGE)) -> temp
# if decide to continue making this look like length data frames, look at boot_length and fishery_length_props



# save the new age data table
saveRDS(new_afreq_data1.0, file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_age_sex_ebs_pcod_Steve_TRIP_STRATA_V1.RDS")
# Note: this data frame only includes age data from haul_joins for which length data was used in the expansion.











#### Age V2
# add columns: SUM_FREQUENCY, WEIGHT1, YAGMH_SFREQ, YAGM_SFREQ, YAG_SFREQ, YG_SFREQ, Y_SFREQ
# Or don't add these columns here because the important ones (SUM_FREQUENCY, YAGMH_SFREQ, and WEIGHT1) have to be recalculated anyway in boot_age.R

# read in the latest data join
new_afreq_data1.0 = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_age_sex_ebs_pcod_Steve_TRIP_STRATA_V1.RDS")
new_afreq_data1.1 = new_afreq_data1.0

new_afreq_data1.1[YEAR==2022,]

new_afreq_data1.1[YEAR==2022, ] %>%
  tidytable::count(HAUL_JOIN) %>%
  print(n=400)

new_afreq_data1.1[YEAR==2022 & HAUL_JOIN=="H25648004533000000049"] %>%
  tidytable::glimpse()
new_afreq_data1.1[YEAR==2022 & HAUL_JOIN=="H25648004533000000049", .(HAUL_JOIN, AGE, LENGTH)] %>%
  tidytable::glimpse() # 3 ages in this haul, two are the same but the associated lengths are different.











#### Unmodified '202' download to test generic capability of baseISS
lfreq_202 = readLines('C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS/sql_files/species_202_generic.sql')

temp2=sql_run(akfin, lfreq_202)

# save
saveRDS(temp2, file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/species_202_generic.RDS")









#### Unmodified all species download for 2022 to test generic capability of baseISS
lfreq_2022 = readLines('C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS/sql_files/all_species_generic_2022.sql')

temp2=sql_run(akfin, lfreq_2022)

# save
saveRDS(temp2, file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/all_species_generic_2022.RDS")





#### Unmodified '201' -pollock download to test generic capability of baseISS
lfreq_201 = readLines('C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS/sql_files/species_201_generic.sql')

temp2=sql_run(akfin, lfreq_201)

# save
saveRDS(temp2, file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/species_201_generic.RDS")









#### SPCOMP for extrapoleted_numbers column for getting 201 to work in expand_by_sampling_strata.R at YAGMH_SNUM
spcomp = readLines('C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS/sql_files/spcomp_generic.sql')

temp2=sql_run(akfin, spcomp)

# save
saveRDS(temp2, file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/spcomp_generic_201.RDS")















