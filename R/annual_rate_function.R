annualRateDrugs <- function(cdm, mainCohort, drugCohortList) {

  result <- cdm[[mainCohort]] %>%
    CohortCharacteristics::summariseCharacteristics(
      cohortIntersectFlag = list(
        "Drugs" = list(indexDate = "cohort_start_date",
                       # censorDate = "cohort_end_date",
                       targetCohortTable = drugCohortList,
                       targetStartDate = "cohort_start_date",
                       targetEndDate = "cohort_end_date",
                       window = list(c(0, Inf)),
                       nameStyle = "{cohort_name}")
      )
    )

  return(result)

}
