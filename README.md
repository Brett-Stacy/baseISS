
<!-- README.md is generated from README.Rmd. Please edit that file -->

# baseISS

<!-- badges: start -->
<!-- badges: end -->

The goal of baseISS is to develop a preliminary bootstrap method for
calculating input sample size (ISS) for fishery-dependent composition
data. This data includes length- and age-frequency data collected by the
NORPAC observer program and excludes fishery-independent data from
surveys. Fishery-dependent composition data represents an important
element of the 26 statistical catch at age stock assessment models for
Alaskan fisheries managed by the NOAA AFSC. The ISS determines the
precision attached to this data type, and therefore regulates (to a
degree) its leverage in assessment model outputs such as biomass
predictions.

The structure and functionality of this package resembles surveyISS with
some notable differences that accommodate the nuances of
fishery-dependent data.As of writing this, baseISS can perform the
bootstrap ISS calculation for EBS Pcod length data, and has been
successfully tested on EBS Pcod age data as well as Pollock length data.

### Process Flow

fishery_iss.R is the primary function that controls all other processes
to calculate ISS. The descriptions of the function arguments in
fishery_iss.R are the key resource for its capability. There are many
options a user can toggle to suit their particular requirements, such as
bootstrapping trips or hauls instead of length or age observations.

This is an example of specifying fishery_iss.R for EBS Pcod:

``` r

fishery_iss(species_code = "202",
            area_code = "EBS",
            length_based = TRUE,
            iters = iterations,
            freq_data = lfreq_data,
            yrs = NULL,
            bin = NULL,
            plus_len = NULL,
            post_strata = NULL,
            minimum_sample_size = list(resolution = "YAGM_SFREQ", size = 30),
            new_trip_N = NULL,
            new_haul_N = NULL,
            new_length_N = NULL,
            max_length = 150,
            boot.trip = TRUE,
            boot.haul = TRUE,
            boot.length = TRUE,
            boot.age = FALSE,
            expand.by.sampling.strata = FALSE,
            expansion_factors = c("haul_numbers", "month_numbers"),
            save_data_frame = TRUE) -> .output
```

### Input Data

The following conditions of an input data frame for any species must be
met:

1.  Age data include associated lengths.

2.  Age data needs to be flattened, meaning every observation has a row
    in the data frame whether it is identical to another or not. This
    ensures that the length measurement associated with the age
    measurement is preserved.

3.  For EBS Pcod, age data has only been used when there exists already
    pre-processed length data associated with it. I.e., I matched the y2
    length data object received from Steve with age data I downloaded
    when testing the baseISS functionality on age data. This was
    necessary because I needed quantities like YAGM_SNUM to perform the
    weighted expansion.

### Current Functionality

1.  Length ISS must be a separate analysis to age ISS. Unlike surveyISS,
    this is necessary for several reasons: a. there will be many more
    hauls with lengths than ages for fishery-dependent data, b. it is
    likely that the user options such as post_stratify will be different
    between length data and age data, and these must be performed
    separately between length and age analyses.

2.  You can’t chose the species from a big data set containing all the
    species like you can in surveyISS. This is because data sets for
    each species should include unique columns necessary to apply their
    unique expansion methods. For EBS Pcod for example, these columns
    are only available after much pre-processing of the raw data. The
    user can input a species-specific data frame into fishery_iss.R and
    run it according to their specifications.

3.  A user can add their species- and area-specific expansion routine to
    expand_props.R. As of writing this, the only official expansion
    routine coded is for EBS Pcod length data from the 2023 assessment.
    There are also placeholder expansion routines for age data for the
    EBS Pcod and length data for Pollock to test the generic
    functionality of baseISS.

### Developing Functionality

- different species - tested with Pollock only. Need to re-test with
  pollock using generic data download.
- reboot_age.R - needs developing
- combine post-strata. needs developing.

### Installation

You can install the development version of baseISS from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("Brett-Stacy/baseISS")
```

### Example

Coming Soon…
