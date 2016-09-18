con <- dbConnect(dbDriver("MySQL"), host='104.154.235.236', password = 'Thesis-Scripting123!', dbname='timeSDM', username='Scripting')

deg1Cells <- 8750
deg0.5Cells <- 35000
deg0.25Cells <- 140000
deg0.1Cells <- 875000


## Get all GBM Records from the Datbase
sql <- "select * from Results INNER JOIN Experiments on Experiments.experimentID = Results.experimentID where model='GBM-BRT';"
gbmRes <- dbGetQuery(con, sql)
g.main <- gbmRes[c('totalTime', 'fittingTime', "predictionTime", 'accuracyTime', 'testingAUC', 'nTrees', 'cores', 'GBMemory', 'taxon', 'trainingExamples', 'spatialResolution')]
g.main$learningRate <- 0.001
g.main$treeComplexity <- 5
g.main$numPredictors <- 5


sql <- "SELECT * FROM GBMParameterRuns;"
gbmPRes <- dbGetQuery(con, sql)
g.param <- gbmPRes[c('totalTime', 'fittingTime', "predictiontime", "accTime", "AUC", "cores", "taxon", "trainingexamples", "spatialResolution", "learningRate", "treeComplexity")]
g.param$nTrees <- NA
g.param$GBMemory <- 3.75
names(g.param) <- c("totalTime", "fittingTime", "predictionTime", "accuracyTime", "testingAUC", "cores", "taxon", 
                    "trainingExamples", "spatialResolution", "learningRate", "treeComplexity", "nTrees", "GBMemory")
g.param$numPredictors <- 5
sql <- "SELECT * FROM PredictorRuns where modelMethod = 'GBM-BRT';"
gbmPredRes <- dbGetQuery(con, sql)
g.pred <- gbmPredRes[c("totalTime", "fittingTime", "predictionTime", "accuracyTime", "testingAUC", "trainingExamples",
                       "spatialResolution", "numPredictors")]
g.pred$cores <- 1
g.pred$GBMemory <- 3.75
g.pred$learningRate <- 0.001
g.pred$treeComplexity <- 5
g.pred$nTrees <- NA
g.pred$taxon <- "Picea"

gbm.full <- rbind(g.param, g.main, g.pred)
gbm.full$cells <- NA
gbm.full$cells[gbm.full$spatialResolution == 0.1] = deg0.1Cells
gbm.full$cells[gbm.full$spatialResolution == 0.25] = deg0.25Cells
gbm.full$cells[gbm.full$spatialResolution == 0.5] = deg0.5Cells
gbm.full$cells[gbm.full$spatialResolution == 1] = deg1Cells
write.csv(gbm.full, "thesis-scripts/data/GBM_ALL.csv")


## Get all MARS Data
sql <- "SELECT * FROM OtherResults2 WHERE method = 'MARS';"
mars <- dbGetQuery(con, sql)

mars <- mars[c("totalTime", "fittingTime","predictionTime", "accTime", "testingAUC", 
               "cores", "GBMemory", "trainingExmaples", "spatialResolution", "taxon")]

names(mars) <- c("totalTime", "fittingTime", "predictionTime", "accuracyTime", "testingAUC", "cores", "GBMemory",
                 "trainingExamples", "spatialResolution", "taxon")

mars$cells <- NA
mars$cells[mars$spatialResolution == 0.1] = deg0.1Cells
mars$cells[mars$spatialResolution == 0.25] = deg0.25Cells
mars$cells[mars$spatialResolution == 0.5] = deg0.5Cells
mars$cells[mars$spatialResolution == 1] = deg1Cells

write.csv(mars, "thesis-scripts/data/mars_full.csv")


### Get all GAM Data 

sql <- "SELECT * FROM OtherResults2 WHERE method = 'GAM';"
gam <- dbGetQuery(con, sql)

gam <- gam[c("totalTime", "fittingTime","predictionTime", "accTime", "testingAUC", 
               "cores", "GBMemory", "trainingExmaples", "spatialResolution", "taxon")]

names(gam) <- c("totalTime", "fittingTime", "predictionTime", "accuracyTime", "testingAUC", "cores", "GBMemory",
                 "trainingExamples", "spatialResolution", "taxon")

gam$cells <- NA
gam$cells[gam$spatialResolution == 0.1] = deg0.1Cells
gam$cells[gam$spatialResolution == 0.25] = deg0.25Cells
gam$cells[gam$spatialResolution == 0.5] = deg0.5Cells
gam$cells[gam$spatialResolution == 1] = deg1Cells

write.csv(gam, "thesis-scripts/data/gam_full.csv")

### Get Random Forests
sql <- "SELECT * FROM RandomForestRuns WHERE trainingExamples IS NOT NULL;"
rf <- dbGetQuery(con, sql)
rf <- rf[c("totalTime", "fitTime", "predTime", "accuracyTime", "AUC", "numTrees", "cores", "GBMemory", "taxon", "method", "trainingExamples")]
names(rf) <- c("totalTime", "fittingTime", "predictionTime", "accuracyTime", "testingAUC", "numTrees", "cores", "GBMemory", "taxon", "method", "trainingExamples")
rf$spatialResolution <- 0.5
rf$GBMemory[rf$cores > 16] <- 30
rf$GBMemory[rf$cores <= 16] <- 16
rf$numPredictors <- 5

sql <-"SELECT * FROM PredictorRuns WHERE modelMethod = 'SRF';"
rf.pred <- dbGetQuery(con, sql)

rf.pred <- rf.pred[c("totalTime", "fittingTime", "predictionTime", "accuracyTime", "testingAUC", "trainingExamples",
                     "spatialResolution", "numPredictors")]
rf.pred$cores <- 1
rf.pred$GBMemory <- 3.75
rf.pred$taxon <- "Picea"
rf.pred$numTrees <- NA
rf.pred$method <- "SERIAL"

rf.full <- rbind(rf, rf.pred)

rf.full$cells <- NA
rf.full$cells[rf.full$spatialResolution == 0.1] = deg0.1Cells
rf.full$cells[rf.full$spatialResolution == 0.25] = deg0.25Cells
rf.full$cells[rf.full$spatialResolution == 0.5] = deg0.5Cells
rf.full$cells[rf.full$spatialResolution == 1] = deg1Cells

write.csv(rf.full, "thesis-scripts/data/rf_full.csv")









