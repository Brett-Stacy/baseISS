


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
new_lfreq_data2.3[YEAR==1989, unique(TRIP_JOIN)] # should be no more NAs, replaced with haul join

# everything checks out as at 8/7/24

# save the new data table with TRIP_JOIN added
saveRDS(new_lfreq_data2, file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP.RDS")















#### Steve's EBS Pcod 2023 y2 object - add strata join ----
# REMEMBER: FOR THIS I WILL NEED TO MATCH UP "HAUL_JOIN" FROM THE PORT DATA WITH THAT FROM THE STRATA.SQL DOWNLOAD. THIS WILL NEED TO CONSIDER THE "P" PREFIX. Probably make a new .sql file that does not concat H or P, but

lfreq_data_trip2 = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/y2_nosex_ebs_pcod_Steve_TRIP.RDS")
sampling_strata = readLines('C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS/sql_files/sampling_strata2.sql') # includes haul_join port_join and sampling_strata

temp_sampling_strata = sql_run(akfin, sampling_strata)
saveRDS(temp_sampling_strata, "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS_data/inputs/sampling_strata2_V1_sql_download.RDS")

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



