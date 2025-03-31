#' Download data from AKFIN needed to run the primary function in baseISS called fishery_iss()
#'
#' @description
#' Connect to AKFIN data base and download species-specific composition data or just haul data to join to composition data required to run fishery_ISS.R.
#'
#' @param akfin_credentials list(uid = userID, pwd = password)
#' @param species_code numeric
#' @param composition_type "LENGTH", or "AGE" in caps, or NULL. NULL retrieves haul data only and will require joining to your length or age data to run fishery_iss.R.
#' @param save_file_path character path including file name, preferably a .RDS file. Save it somewhere confidential. If NULL, doesn't save anything.
#'
#' @return tidytable data frame ready for use in baseISS
#'
#' @export
#'
download_akfin_data <- function(akfin_credentials,
                                species_code,
                                composition_type = NULL,
                                save_file_path = NULL)
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
    system.file("sql/generic_trip.sql", package = "baseISS") %>%
      readLines() -> trip_data_sql
    trip_data = sql_run(akfin, trip_data_sql)


    # Extrapolated number and weight by HAUL_JOIN used for weighted expansion in baseISS
    system.file("sql/species_extrapolated_number_weight.sql", package = "baseISS") %>%
      readLines() -> haul_data_sql
    # modify haul_data_sql with species code
    haul_data_sql = gsub("XXX", species_code, haul_data_sql)
    haul_data = sql_run(akfin, haul_data_sql)


    # Join
    haul_data %>%
      tidytable::drop_na(HAUL_JOIN) %>%
      tidytable::left_join(trip_data) -> out_data







  }else{
    # Download haul data and composition data

    # TRIP_JOIN is defined here as unique CRUISE, PERMIT, TRIP_SEQ for the purposes of an observer trip needed for bootstrapping trips in fishery_iss.R. These columns are only available together in the debriefed_haul_mv database
    system.file("sql/generic_trip.sql", package = "baseISS") %>%
      readLines() -> trip_data_sql
    trip_data = sql_run(akfin, trip_data_sql)


    # Extrapolated number and weight by HAUL_JOIN used for weighted expansion in baseISS
    system.file("sql/species_extrapolated_number_weight.sql", package = "baseISS") %>%
      readLines() -> haul_data_sql
    # modify haul_data_sql with species code
    haul_data_sql = gsub("XXX", species_code, haul_data_sql)
    haul_data = sql_run(akfin, haul_data_sql)


    # Composition data
    if(composition_type=="LENGTH"){


      # Length composition data
      system.file("sql/species_length_composition.sql", package = "baseISS") %>%
      # system.file("sql/CopyOfspecies_length_composition.sql", package = "baseISS") %>%
        readLines() -> lcomp_data_sql
      # modify with species code
      lcomp_data_sql = gsub("XXX", species_code, lcomp_data_sql)
      comp_data = sql_run(akfin, lcomp_data_sql)



    }else if(composition_type=="AGE"){


      # Age composition data
      system.file("sql/species_age_composition.sql", package = "baseISS") %>%
        readLines() -> acomp_data_sql
      # modify with species code
      acomp_data_sql = gsub("XXX", species_code, acomp_data_sql)
      comp_data = sql_run(akfin, acomp_data_sql)

    }

    # Join
    comp_data %>%
      tidytable::drop_na(composition_type) %>%
      tidytable::left_join(haul_data) %>%
      tidytable::left_join(trip_data) %>%
      tidytable::mutate(TRIP_JOIN = paste(CRUISE, PERMIT, TRIP_SEQ, sep = "-")) -> out_data
  }

  # Save
  if(!is.null(save_file_path)){
    saveRDS(out_data, file = save_file_path)

  }
  return(out_data)
}

