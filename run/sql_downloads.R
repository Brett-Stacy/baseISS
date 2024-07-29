


# Need to connect to AKFIN with username and passoword to run below code.



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


#### Take 2, manual trip join
# let's try to make a unique trip join identifier using Jen's suggested combination of Cruise, Permit, and trip_seq
lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/y2_ebs_pcod_Brett.RDS")
lfreq2 = readLines('C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS/sql_files/test2.sql') # test2.sql includes Cruise, Permit, and trip_seq

temp2=sql_run(akfin, lfreq2)
joinDT2 = data.table::setDT(temp2)

joinDT2 %>%
  tidytable::mutate(TRIP_JOIN = paste(CRUISE, PERMIT, TRIP_SEQ, sep = "-")) %>%
  tidytable::select(HAUL_JOIN, TRIP_JOIN) -> .joinDT2 # there are NAs in TRIP_SEQ so they show up in this joined ID but it's still better than the TRIP_JOIN that comes with the data download

# join it with the input data frame for baseISS
new_lfreq_data2 = tidytable::left_join(lfreq_data, .joinDT2) # this looks better

# save the new data table with TRIP_JOIN added
saveRDS(new_lfreq_data2, file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/y2_ebs_pcod_Brett_TRIP.RDS")










#### Incorporate sampling strata column
# for use in bootstrapping within strata
lfreq_data_trip = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/y2_ebs_pcod_Brett_TRIP.RDS")
sampling_strata = readLines('C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/baseISS/sql_files/sampling_strata.sql') # includes haul_join and sampling_strata

temp_sampling_strata = sql_run(akfin, sampling_strata)
joinDT_temp = data.table::setDT(temp_sampling_strata)

# join it with the input data frame for baseISS
new_lfreq_data3 = tidytable::left_join(lfreq_data, joinDT_temp) # this looks better

# save the new data table with TRIP_JOIN added
saveRDS(new_lfreq_data3, file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/y2_ebs_pcod_Brett_TRIP_STRATA.RDS")


# play with it
new_lfreq_data3[,.N, by=.(SAMPLING_STRATA_NAME, YEAR)] %>% print(n=100)






