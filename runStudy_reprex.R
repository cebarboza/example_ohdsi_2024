#' ---
#' output: reprex::reprex_document
#' ---

library(TestGenerator)
library(CohortCharacteristics)
library(CodelistGenerator)
library(DrugUtilisation)
library(CDMConnector)
library(here)
library(dplyr)

source("R/annual_rate_function.R")

cdm <- TestGenerator::patientsCDM(pathJson = here::here("testCases"),
                                  testName = "icu_sample_population")

cdm[["person"]]

# ICU Cohort
icu_visits <- here::here("cohort")
icu_visits_cohort <- CDMConnector::readCohortSet(icu_visits)
cdm <- CDMConnector::generate_cohort_set(cdm, icu_visits_cohort, name = "icu_visits")

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

icu <- cdm[["icu_visits"]] %>% collect()
drugs <- cdm[["drugs_cohort"]] %>% collect()
TestGenerator::graphCohort(6, cohorts = list("icu_visits" = icu,
                                             "drugs_cohort" = drugs))

# View(result)
result

# reprex(input = "runStudy.R", wd = here::here())
