#' Download data from AKFIN needed to run the primary function in baseISS called fishery_iss()
#'
#' @description
#' Connect to AKFIN data base and download species-specific composition data or just haul data to join to composition data required to run fishery_ISS.R.
#' The inputs required are species code.
#'
#' @param akfin_credentials list(uid = userID, pwd = password)
#' @param species_code numeric
#' @param composition_type "length", or "age", or NULL. NULL retrieves haul data only and will require joining to your length or age data to run fishery_iss.R.
#' @param save_file_path character path including file name, preferably a .RDS file. Save it somewhere confidential.
#'
#' @return tidytable data frame ready for use in baseISS
#'
#' @export
#'
download_akfin_data <- function(akfin_credentials,
                                species_code,
                                composition_type)
{
  # Login to akfin
  akfin = DBI::dbConnect(odbc::odbc(), dsn = "AKFIN", uid = akfin_credentials$uid,
                         pwd = akfin_credentials$pwd)

  # Function for running sql query
  sql_run <- function(database, query) {
    query = paste(query, collapse = "\n")
    DBI::dbGetQuery(database, query, as.is=TRUE, believeNRows=FALSE)
  }





  # Download data files for either haul data only or including composition data
  if(is.null(composition_type)){
    # Download haul data but not composition data

    # TRIP_JOIN is defined here as unique CRUISE, PERMIT, TRIP_SEQ for the purposes of an observer trip needed for bootstrapping trips in fishery_iss.R. These columns are only available together in the debriefed_haul_mv database
    system.file("inst/sql/generic_trip.sql", package = "baseISS") %>%
      readLines() -> trip_data_sql

    trip_data = sql_run(akfin, trip_data_sql)


    # Extrapolated number and weight by HAUL_JOIN used for weighted expansion in baseISS
    system.file("inst/sql/species_extrapolated_number_weight.sql", package = "baseISS") %>%
      readLines() -> haul_data_sql

    haul_data = sql_run(akfin, haul_data_sql)




  }else{
    # Download haul data and composition data
  }






}

