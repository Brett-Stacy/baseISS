#' Fishery input sample size function
#'
#' @description
#' Bootstrap data sources to replicate EBS Pcod fishery observer measurements of length composition
#' for computation of input sample size. Follows loosely srvy_iss.R from surveyISS package.
#'
#' @param iters number of iterations
#' @param lfreq_data  length frequency input dataframe
#' @param yrs any year filter >= (default = NULL)
#' @param boot_thl Boolean. Resample trips, hauls, and lengths w/replacement? (default = FALSE). FALSE will return og proportions-at-length
#'
#' @return Dataframe of input sample size by year
#'
#' @export
#'
# TESTING
iters = 1
lfreq_data = readRDS(file = "C:/Users/bstacy2/OneDrive - UW/UW Postdoc/GitHub Repos/y2_ebs_pcod_Brett.RDS")
yrs = 2021
boot_thl = TRUE
fishery_iss <- function(iters = 1,
                        lfreq_data,
                        yrs = NULL,
                        boot_thl = FALSE){

  # get original population proportions-at-length values ----
  og_l_props = fishery_length_props(lfreq_data = lfreq_data,
                                    yrs = yrs,
                                    boot_thl = FALSE)






}
