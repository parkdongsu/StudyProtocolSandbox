execute <- function(connectionDetails,
                 databaseName,
                 cdmDatabaseSchema,
                 cohortDatabaseSchema,
                 cohortTable,
                 outputFolder,
                 createCohorts = T,
                 runValidation = T,
                 packageResults = T,
                 minCellCount = 5){

  if (!file.exists(outputFolder))
    dir.create(outputFolder, recursive = TRUE)

OhdsiRTools::addDefaultFileLogger(file.path(outputFolder, "log.txt"))

if(createCohorts){
  OhdsiRTools::logInfo("Creating Cohorts")
  createCohorts(connectionDetails,
                       cdmDatabaseschema=cdmDatabaseschema,
                       cohortDatabaseschema=cohortDatabaseschema,
                       cohortTable=cohortTable,
                       outputFolder = outputFolder)
}

if(runValidations){
  OhdsiRTools::logInfo("Validating Models")
# for each model externally validate
analysesLocation <- system.file("plp_models",
                               package = "SkeletonValidationStudy")
val <- PatientLevelPrediction::evaluateMultiplePlp(analysesLocation = analysesLocation,
                           outputLocation = outputFolder,
                           connectionDetails = connectionDetails,
                           validationSchemaTarget = cohortDatabaseSchema,
                           validationSchemaOutcome = cohortDatabaseSchema,
                           validationSchemaCdm = cdmDatabaseSchema,
                           databaseNames = databaseName,
                           validationTableTarget = cohortTable,
                           validationTableOutcome = cohortTable)
}

# package the results: this creates a compressed file with sensitive details removed - ready to be reviewed and then
# submitted to the network study manager

# results saved to outputFolder/databaseName
if (packageResults) {
  OhdsiRTools::logInfo("Packaging results")
  packageResults(outputFolder = file.path(outputFolder, databaseName),
                 minCellCount = minCellCount)
}


invisible(NULL)

}

