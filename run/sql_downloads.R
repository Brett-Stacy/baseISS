


# Need to connect to AKFIN with username and passoword to run below code.

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











#### Steve's EBS Pcod 2023 y2 object - add trip join ----

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
joinDT2.2 = data.table::setDT(temp2.2)

joinDT2.2 %>%
  tidytable::mutate(TRIP_JOIN = paste(CRUISE, PERMIT, TRIP_SEQ, sep = "-")) %>%
  tidytable::select(YEAR, HAUL_JOIN, TRIP_JOIN) -> .joinDT2.2
# LEFT OFF HERE 8/6: NEED TO MODIFY BELOW TRIP_JOIN ASSIGNMENT BASED OF NOTEBOOK NOTES:
# MODIFY TRIP JOIN TO BE HAUL JOIN BECAUSE IT WAS ORIGINALLY PORT JOIN AND THIS IS DIRECTLY COMPRABLE TO TRIP JOIN.
# THEN DEAL WITH HAUL JOIN SOMEHOW. CAN PROBABLY JUST LEAVE IT AS IS BECAUSE WE JUST NEED IT TO STAY ONE HAUL PER TRIP JOIN
# ALSO: NEED FOREIGN ONBOARD OBSERVER TRIP RECORDS 1977-1990. PROBABLY JUST CALL THIS CRUISE FOR NOW UNTIL I CAN GET THE FOREIGN TRIP DATA LIKE I GOT THE DOMESTIC TRIP SEQUENCE

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

# Transfer haul_join to trip_join, adding year to make sure it is a unique identifier. Do this only for port ("P" prefix) data to avoid doing it for foriegn data as well as port.
new_lfreq_data2[substr(HAUL_JOIN, 1, 1)=="P"] %>%
  tidytable::mutate(TRIP_JOIN = base::paste(YEAR, HAUL_JOIN, sep = "-")) -> new_lfreq_data2.2

# save the new data table with TRIP_JOIN added
saveRDS(new_lfreq_data2, file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP.RDS")






#### Steve's EBS Pcod 2023 y2 object - add strata join ----
# REMEMBER: FOR THIS I WILL NEED TO MATCH UP "HAUL_JOIN" FROM THE PORT DATA WITH THAT FROM THE STRATA.SQL DOWNLOAD. THIS WILL NEED TO CONSIDER THE "P" PREFIX. Probably make a new .sql file that does not concat H or P, but

