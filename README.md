
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
some notable differences that accomodate the neuances of
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

### Current Functionality

### Developing Functionality

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
