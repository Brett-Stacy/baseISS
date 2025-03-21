
<!-- README.md is generated from README.Rmd. Please edit that file -->

# baseISS

<!-- badges: start -->
<!-- badges: end -->

The goal of baseISS is to develop a preliminary method for calculating
input sample size (ISS) for fishery-dependent composition data. This
data includes length- and age-frequency data collected by the NORPAC
observer program and excludes fishery-independent data from surveys.
Fishery-dependent composition data represents an important element of
the 26 statistical catch at age stock assessment models for Alaskan
fisheries managed by the NOAA AFSC. The ISS determines the precision
attached to this data type, and therefore regulates its leverage in
assessment model outputs such as biomass predictions.

The structure and functionality of this package resembles surveyISS with
some notable differences that accommodate the nuances of
fishery-dependent data. These are covered in the next section,
“Important Notes”.

## Important Notes

### Input Data

The following conditions of an input data frame for any species must be
met: 1. (length data) There exists a WEIGHT1 column that represents the
haul-level proportions-at-length of the observed lengths. This is
calculated by dividing the frequency of the observed length within a
haul by the total number of fish lengthed in that haul. It should be a
standard calculation that is exactly the same for every species.

2.  Length data be condensed with sum_frequency column.

3.  Age data include associated lengths.

4.  Age data flattened, no “sum_frequency” column.

5.  For EBS Pcod, age data has only been used when there exists already
    pre-processed length data associated with it. I.e., I matched the y2
    length data object recieved from Steve with age data I downloaded
    when testing the baseISS functionality on age data. This was
    necessary becasue I needed quantities like YAGM_SNUM to perform the
    weighted expansion.

### Current Functionality

1.  Length ISS must be a separate analysis to age ISS. Unlike surveyISS,
    this is necessary for several reasons: a. there will be many more
    hauls with lengths than ages, b. it is likely that the user options
    such as post_stratify will be different between length data and age
    data, c. NOTE ANOTHER ONE WHEN YOU REMEMBER.

2.  You can’t chose the species from a big data set containing all the
    species. This is because data sets for each species should include
    unique columns necessary to apply their unique expansion methods.
    For EBS Pcod for example, these columns are only available after
    much pre-processing and calculating of the raw data.

### Developing Functionality

- subsampling length - done.

- custom max length control - done.

- plus group option - done.

- different length bin size control - done.

- different species - tested with Pollock only.

- reboot_age.R

## Installation

You can install the development version of baseISS from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("Brett-Stacy/baseISS")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(baseISS)
#> Loading required package: data.table
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
