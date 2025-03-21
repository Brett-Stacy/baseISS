% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generic_sample_change_trip_N.R
\name{generic_sample_change_trip_N}
\alias{generic_sample_change_trip_N}
\title{Resample trips w/replacement as a vector of user-defined length}
\usage{
generic_sample_change_trip_N(flex.vec, new_trip_N = NULL, vec_length = NULL)
}
\arguments{
\item{flex.vec}{flexible (can be length 1) vector of input elements}

\item{new_trip_N}{user-defined sample size adjustment options defined in fishery_iss()}

\item{vec_length}{pass the useful .N to this function as vec_length}
}
\value{
vector of resampled elements
}
\description{
Modified generic_sample() function to allow more flexibility based on user-defined options for adjusting number of trips as a proportion
}
