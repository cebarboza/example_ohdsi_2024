*Local `.Rprofile` detected at `D:\Users\cbarboza\Documents\darwin-docs\example_ohdsi_2024\.Rprofile`*

``` r
library(TestGenerator)
library(CohortCharacteristics)
library(CodelistGenerator)
library(DrugUtilisation)
library(CDMConnector)
library(here)
#> here() starts at D:/Users/cbarboza/Documents/darwin-docs/example_ohdsi_2024
```

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

``` r

source("R/annual_rate_function.R")

cdm <- TestGenerator::patientsCDM(pathJson = here::here("testCases"),
                                  testName = "icu_sample_population")
#> ! cdm name not specified and could not be inferred from the cdm source table
#> ✔ Patients pushed to blank CDM successfully
```

``` r

cdm[["person"]]
#> # Source:   table<main.person> [8 x 18]
#> # Database: DuckDB v0.10.2 [cbarboza@Windows 10 x64:R 4.3.1/C:\Users\cbarboza\AppData\Local\Temp\RtmpkJuyNz\file622433b64e0b.duckdb]
#>   person_id gender_concept_id year_of_birth month_of_birth day_of_birth
#>       <int>             <int>         <int>          <int>        <int>
#> 1         1              8532          1980             NA           NA
#> 2         2              8507          1990             NA           NA
#> 3         3              8532          2000             NA           NA
#> 4         4              8507          1980             NA           NA
#> 5         5              8532          1990             NA           NA
#> 6         6              8507          2000             NA           NA
#> 7         7              8532          1980             NA           NA
#> 8         8              8507          1990             NA           NA
#> # ℹ 13 more variables: birth_datetime <dttm>, race_concept_id <int>,
#> #   ethnicity_concept_id <int>, location_id <int>, provider_id <int>,
#> #   care_site_id <int>, person_source_value <chr>, gender_source_value <chr>,
#> #   gender_source_concept_id <int>, race_source_value <chr>,
#> #   race_source_concept_id <int>, ethnicity_source_value <chr>,
#> #   ethnicity_source_concept_id <int>
```

``` r

# ICU Cohort
icu_visits <- here::here("cohort")
icu_visits_cohort <- CDMConnector::readCohortSet(icu_visits)
cdm <- CDMConnector::generate_cohort_set(cdm, icu_visits_cohort, name = "icu_visits")
#> ℹ Generating 1 cohort
#> ℹ Generating cohort (1/1) - icu_visits✔ Generating cohort (1/1) - icu_visits [223ms]
```

``` r

# Drugs ConceptSets

drugsConceptSets <- here::here("concept_sets", "drugs")
drugConcepts <- CodelistGenerator::codesFromConceptSet(drugsConceptSets, cdm)

# names(drugConcepts)

cdm <- DrugUtilisation::generateDrugUtilisationCohortSet(cdm,
                                                         name = "drugs_cohort",
                                                         conceptSet = drugConcepts,
                                                         durationRange = c(1, Inf),
                                                         imputeDuration = "none",
                                                         gapEra = 1,
                                                         priorUseWashout = 0,
                                                         priorObservation = 0,
                                                         cohortDateRange = as.Date(c(NA, NA)),
                                                         limit = "all")

# In this study, we want to know how many people took the the specific set of
# medications during their ICU stay. We expect that subject 6 and 3 were exposed to
# the medication during their ICU stay, but in our result we get 3 people.


result <- annualRateDrugs(cdm,
                          mainCohort = "icu_visits",
                          drugCohortList = "drugs_cohort")
#> ℹ adding demographics columns
#> ℹ adding cohortIntersectFlag 1/1ℹ summarising data
#> ✔ summariseCharacteristics finished!
```

``` r

icu <- cdm[["icu_visits"]] %>% collect()
drugs <- cdm[["drugs_cohort"]] %>% collect()
TestGenerator::graphCohort(6, cohorts = list("icu_visits" = icu,
                                             "drugs_cohort" = drugs))
#> Warning in geom_segment(aes(x = cohort_start_date, y = cohort, xend =
#> cohort_end_date, : Ignoring unknown aesthetics: fill
```

![](https://i.imgur.com/AVxaVW2.png)<!-- -->

``` r

# View(result)
result
#> # A tibble: 43 × 13
#>    result_id cdm_name            group_name group_level strata_name strata_level
#>        <int> <chr>               <chr>      <chr>       <chr>       <chr>       
#>  1         1 An OMOP CDM databa… cohort_na… icu_visits  overall     overall     
#>  2         1 An OMOP CDM databa… cohort_na… icu_visits  overall     overall     
#>  3         1 An OMOP CDM databa… cohort_na… icu_visits  overall     overall     
#>  4         1 An OMOP CDM databa… cohort_na… icu_visits  overall     overall     
#>  5         1 An OMOP CDM databa… cohort_na… icu_visits  overall     overall     
#>  6         1 An OMOP CDM databa… cohort_na… icu_visits  overall     overall     
#>  7         1 An OMOP CDM databa… cohort_na… icu_visits  overall     overall     
#>  8         1 An OMOP CDM databa… cohort_na… icu_visits  overall     overall     
#>  9         1 An OMOP CDM databa… cohort_na… icu_visits  overall     overall     
#> 10         1 An OMOP CDM databa… cohort_na… icu_visits  overall     overall     
#> # ℹ 33 more rows
#> # ℹ 7 more variables: variable_name <chr>, variable_level <chr>,
#> #   estimate_name <chr>, estimate_type <chr>, estimate_value <chr>,
#> #   additional_name <chr>, additional_level <chr>
```

``` r

# reprex(input = "runStudy.R", wd = here::here())
```

<sup>Created on 2024-06-01 with [reprex v2.1.0](https://reprex.tidyverse.org)</sup>
