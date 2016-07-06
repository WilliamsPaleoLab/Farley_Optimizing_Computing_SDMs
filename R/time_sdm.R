## Welcome to the timeSDM script.
## This script manages database sessions, gets experiments, and then times the execution of a boosted regression tree species distribution model
## Designed to be run in a cloud computing environment.
## Author: Scott Farley
## Email: sfarley2@wisc.edu
## Open source licensed under the MIT License

## get command line arguments
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  globals.numIters = 5  ## default number of runs
  globals.shutdownOnFinish = TRUE
  globals.doInstall = TRUE
} else if (length(args)==1) {
  globals.numIters = args[1]
  globals.shutdownOnFinish = TRUE
  globals.doInstall = TRUE
}else if (length(args) == 2){
  globals.numIters = args[1]
  globals.shutdownOnFinish = args[2] ## shutdown the virtual machine when the script finishes execution
  globals.doInstall = TRUE
}else if (length(args) == 3){
  globals.numIters = args[1]
  globals.shutdownOnFinish = args[2]
  globals.doInstall = args[3]
}

if (globals.doInstall){
  install.packages(c("dismo", "raster", "gbm", "SDMTools", "RMySQL", "rgdal", "gam", "earth"), repos='http://cran.mtu.edu/')
  install.packages("RMySQL", repos='http://cran.mtu.edu/')
}

## load external libraries
library(gbm) ## base pacakges for regression trees
library(dismo) ## SDM package --> boosted regression tree function
library(raster) ## for raster manipulation
library(SDMTools) ## for accuracy assessment
library(RMySQL) ## for database communication
library(rgdal)
library(parallel)

setwd("/home/rstudio")

##load in the config script
source("thesis-scripts/R/config.R")


## get system details
source("thesis-scripts/R/linux_getVars.R")
systemInfo <- getSystemVars()
RInfo <- getRVars()


# ## initialization
globals.ncores = detectCores()
nodename <- Sys.info()['nodename']
nodeSplit <- strsplit(nodename, "-")
globals.totalMemory = systemInfo[['totalMem']]
globals.experimentMemory = nodeSplit[['nodename']][3]
print(globals.experimentMemory)
globals.experimentMemory = 4
globals.nreps = 10
globals.saveThreshold = 0.25

rownames <- c("pollenThreshold", "presenceThreshold", "TotalTime", "fitTime", "predTime", "accTime",
              "AUC", "ommission.rate", "sensitivity", "specificty", "prop.correct", "Kappa",
              'NumTrees', 'meanCVDeviance', 'seCVDeviance', 'meanCVCorrelation', 'seCVCorrelation', 'meanCVRoc', 'seCVRoc', 'trainingResidualDeviance', 'trainingMeanDeviance',
              'trainingCorrelation', 'trainingROC', "Timestamp")

startSession <- function(con){
  ## insert into the main session table
  sql <- "INSERT INTO SessionsManager VALUES(DEFAULT, 'STARTED', DEFAULT, NULL, 0, current_timestamp);"
  dbGetQuery(con, sql)
  ## get that id
  lastID <- dbGetQuery(con, "SELECT LAST_INSERT_ID();")
  ## now insert into the other tables
  ## computer
  sql <- paste("INSERT INTO SessionsComputer VALUES (DEFAULT, ",lastID,",'", systemInfo[['osFamily']], "','", systemInfo[['osRelease']], "','", systemInfo[['osVersion']], "','",
          systemInfo[['nodeName']], "','", systemInfo[['machineArchitecture']], "','", systemInfo[['numCPUs']], "','", systemInfo[['threadsPerCPU']],"','", systemInfo[['cpuVendor']], "','",
          systemInfo[['cpuModelNumber']], "','", systemInfo[['cpuModelName']], "','", systemInfo[['cpuClockRate']], "','", systemInfo[['cpuMIPS']], "','", systemInfo[['Hypervisor']],
          "','", systemInfo[['virtualization']], "','", systemInfo[['L1d']], "','", systemInfo[['L1i']], "','", systemInfo[['L2']], "','", systemInfo[['L3']], "','", systemInfo[['totalMem']],
          "','", systemInfo[['swapMem']], "');", sep="")
  dbSendQuery(con, sql)
  ##this is R version stuff
  sql <- paste("INSERT INTO SessionsR VALUES (DEFAULT,", lastID, ",'", RInfo[['rPlatform']], "','", RInfo[['rVersion']], "','", RInfo[['rnickname']], "');", sep="")
  dbSendQuery(con, sql)
  return(lastID)
}

getAllAvailableExperiments <- function(con, verbose=TRUE){
  sql <- paste("SELECT * FROM Experiments WHERE cores=", globals.ncores, " AND GBMemory=", globals.experimentMemory, " AND experimentStatus = 'NOT STARTED';", sep="")
  rows <- dbGetQuery(con, sql)
  print(paste("I am ", systemInfo[['nodeName']], ". I Have found: ", nrow(rows), " available experiments for ", globals.ncores, "core(s) and ", globals.experimentMemory, "GB Memory"))
  return(rows)
}

getNextAvailableExperiment <- function(con){
  ## select random row within this computer's capacity so not all experiments are done on one session
  sql <- paste("SELECT * FROM Experiments WHERE cores=", globals.ncores, " AND GBMemory=", globals.experimentMemory, " AND experimentStatus = 'NOT STARTED' OR experimentStatus='INTERRUPTED' OR experimentStatus='DONE - OLD' ORDER BY rand() LIMIT 1;", sep="")
  rows <- dbGetQuery(con, sql)
  return(rows)
}

runNextExperiment <- function(experiment, con, sessionID){
  ## takes in an experiment (database row) and delegates a timer on it
  print(paste("Running experiment #", experiment['experimentID'][[1]]))
  expLog = paste("R-Process: Started Experiment #", experiment['experimentID'][[1]])
  system2("logger", args=expLog)
  # pick out the important parts of the vector for later use
  expID <- experiment['experimentID'][[1]]
  cellID <- experiment['cellID'][[1]]
  replicateNumber <- experiment[['replicateID']]
  taxon <- experiment['taxon'][[1]]
  spatialRes <- experiment['spatialResolution'][[1]]
  numTraining <- experiment['trainingExamples'][[1]]
  ## update the experiments table to tell the database that we're starting the experiment
  sql = paste("UPDATE Experiments SET experimentStatus='STARTED', experimentStart=current_timestamp, experimentLastUpdate=current_timestamp, sessionID=", sessionID ," WHERE experimentID=", expID, ";", sep="")
  dbSendQuery(con, sql)
  errorMessage = FALSE
  modelMethod = experiment['model'][[1]]

  ## decide if we need to save the output
  rand <- runif(1, 0, 1)
  if (rand < globals.saveThreshold){
    save =  TRUE
    saveName = expID
  }else{
    save = FALSE
    saveName = "none"
  }

  #*********DO THE RUN*********
  res <- tryCatch(timeSDM(taxon, globals.ncores, globals.totalMemory, numTraining, spatialRes, save=save, imgName=saveName),  ##this is the run here
                  error=function(e){ ## catch if the run raises an error
                    errorMessage = TRUE
                    print(e)
                    return(c(FALSE))
                  })
  if ((res[1] == FALSE) || (errorMessage== TRUE)){ ## report the error and advance if we can't finish this experiment
        sql <- paste("UPDATE Experiments SET experimentStatus='ERROR', experimentLastUpdate=current_timestamp WHERE experimentID=", expID, ";", sep="")
        dbSendQuery(con, sql)
        return(FALSE) ## advance to next loop iteration
  }
  ## if it was not an error, we can put it in the database as a success
  sql <- paste("UPDATE Experiments SET experimentStatus='DONE', experimentEnd=current_timestamp, experimentLastUpdate=current_timestamp WHERE experimentID=", expID, ";", sep="")
  dbSendQuery(con, sql)
  ## and we can insert the results into the results table
  sql <- paste("INSERT INTO Results VALUES (DEFAULT, ",
               expID,  # experiment ID
               ",", sessionID, # sessionID
               ",'", res[1],  #pollen threshold
               "',", res[2], # presence threshold
               ",", res[3], # totalTime
               ",",res[4], #fit time
               ",", res[5], # predictionTime
               ",", res[6], #accuracyTime
               ",", res[7], ## AUC
               ",", res[8], ## OR
               ",", res[9], ## sensitivity
               ",", res[10],##specificity
               ",", res[11], ##propCorrect
               ",", res[12], ##kapaa
               ",", res[13], ##numTrees
               ",", res[14],##meanDev
               ",", res[15],##seDev
               ",", res[16], ##meanCor
               ",", res[17], ##seCor
               ",", res[18], ##meanROC
               ",", res[19], ##seROC
               ",", res[20], ##resDev
               ",", res[21], ##meanDev
               ",", res[22], ##trainingCor
               ",", res[23], ##trainingROC
               ", DEFAULT, ", ## current_timestamp
               cellID,  ##cell number
               ",", replicateNumber,  ## replicate number
               ",'" , globals.totalMemory, "');" ## real Memory
               , sep="")
  dbSendQuery(con, sql) ## results query

  sql = paste("UPDATE SessionsManager SET replicatesRun = replicatesRun + 1, tableLastUpdate=current_timestamp WHERE sessionID=", sessionID, ";", sep="")
  dbSendQuery(con, sql) ## update the sessions manager

  print(paste("Finished running experiment#", expID))
}

## predictor rasters
## HADGem 2100 monthly averages
## bioclimatic vars 2, 7, 8, 15, 18, 19
predPath <- "thesis-scripts/data/predictors/standard_biovars/"

pred_1deg <- stack(paste(predPath, "1_deg/", "standard_biovars_1_deg_2100.tif", sep=""))
pred_05deg <- stack(paste(predPath, "0_5_deg/", "standard_biovars_0_5_deg_2100.tif", sep=""))
pred_025deg <- stack(paste(predPath, "0_25_deg/", "standard_biovars_0_25_deg_2100.tif", sep=""))
pred_0_1deg <- stack(paste(predPath, "0_1_deg/", "standard_biovars_0_1_deg_2100.tif", sep=""))

names(pred_1deg) <- c("bio2", "bio7", "bio8", "bio15", "bio18", "bio19")
names(pred_05deg) <- c("bio2", "bio7", "bio8", "bio15", "bio18", "bio19")
names(pred_025deg) <- c("bio2", "bio7", "bio8", "bio15", "bio18", "bio19")
names(pred_0_1deg) <- c("bio2", "bio7", "bio8", "bio15", "bio18", "bio19")

## load the occurrences
## prethresholded and filtered to only include the above bioclimatic vars
occPath <- "thesis-scripts/data/occurrences/"
quercus_points <- read.csv(paste(occPath, "quercus_ready.csv", sep=""))
betula_points <- read.csv(paste(occPath, "betula_ready.csv", sep=""))
tsuga_points <- read.csv(paste(occPath, "tsuga_ready.csv", sep=""))
picea_points <- read.csv(paste(occPath, "picea_ready.csv", sep=""))
sequoia_points <- read.csv(paste(occPath, "sequoia_ready.csv", sep=""))



timeSDM<-function(species, ncores, memory, nocc, sr, testingFrac = 0.2, plot_prediction=F, pollen_threshold='auto',
  presence_threshold='auto', presence_threshold.method='maxKappa', percentField='pollenPercentage', 
  save=FALSE, saveLocation='/home/rstudio/thesis-scripts/model-output', imgName="rasterOutput", modelMethod='GBM-BRT'){

  startTime <- proc.time()
  ## get the right species points
  if (species == "Sequoia"){
    points <- sequoia_points
  }else if (species == 'Quercus'){
    points <- quercus_points
  }else if (species == "Betula"){
    points <- betula_points
  }else if (species == "Tsuga"){
    points<- tsuga_points
  }else if (species == "Picea"){
    points<- picea_points
  }else{
    print("Invalid species name.")
    return(FALSE)
  }

  if (sr == 1){
    pred <- pred_1deg
  }else if (sr==0.5){
    pred <- pred_05deg
  }else if (sr==0.25){
    pred <- pred_025deg
  }else if (sr == 0.1){
    pred <- pred_0_1deg
  }else{
    print("Invalid spatial resolution")
    return(FALSE)
  }

  ## define the presence threshold from the pollen percentage data as defined by Nieto-Lugilde et al 2015
  ## using the VAR_05 method
  ## calculate the maximum percentage for the taxon then take 5% of that
  if (pollen_threshold == 'auto'){
    m <- max(points[percentField])
    pollen_threshold <- m * 0.05
  }## else, its whatever is set in args

  ##do the thresholding
  points['presence'] <- points[percentField]
  points['presence'][points['presence'] < pollen_threshold] = 0
  points['presence'][points['presence'] >= pollen_threshold] = 1


  ## Take a testing set
  q <- nrow(points)
  q_test <- testingFrac*q
  testing_set <- points[sample(q, q_test), ] ## select q_test random rows from points

  ## now take a random sampling on nocc rows
  if (nocc < q){
    training_set <- points[sample(q, nocc), ] ## this is what we will build the model upon
  }else{
    training_set <- points[sample(q, q*0.8), ] ## hack around for debug on small files
  }

  training_set <- na.omit(training_set)

  ####*******Train the Model ******######
  fitStart <- proc.time()
  model <- "NEW" ##overwrite
  if (modelMethod == 'GBM-BRT') {
    model <- gbm.step(training_set, gbm.y="presence", gbm.x= c("bio2", "bio7", "bio8", "bio15", "bio18", "bio19"),
                      tree.complexity=5, learning.rate=0.001, verbose=FALSE, silent=TRUE, max.trees=100000000000, plot.main=FALSE, plot.folds = FALSE)
  }else if (modelMethod == 'MARS'){
    x <- training_set[c('bio2', 'bio7', 'bio8', 'bio15', 'bio18', 'bio19', 'presence')]
    f = as.formula(paste('presence ~ ', paste('bio2', 'bio7', 'bio8', 'bio15', 'bio18', 'bio19', sep=' + ')))
    model <- earth(f, data=x)
  }else if (modelMethod == 'SVM'){
    x <- training_set[c('bio2', 'bio7', 'bio8', 'bio15', 'bio18', 'bio19', 'presence')]
    f = as.formula(paste('presence ~ ', paste('bio2', 'bio7', 'bio8', 'bio15', 'bio18', 'bio19', sep=' + ')))
    model <- svm(f, data=x)
  }else if (modelMethod == 'GAM'){
    x <- training_set[c('bio2', 'bio7', 'bio8', 'bio15', 'bio18', 'bio19', 'presence')]
    f = as.formula(paste('presence ~ ', paste('bio2', 'bio7', 'bio8', 'bio15', 'bio18', 'bio19', sep=' + ')))
    model <- gam(f, data=x)
  }

  if (is.null(model)){
    stop("Got null model.")
  }
  fitEnd <- proc.time()
  fitTime <- fitEnd - fitStart


  ####*******Predict the Model ******######
  predStart <- proc.time()
  if (modelMethod == 'GBM-BRT'){
    prediction <-predict(pred, model, n.trees=model$gbm.call$best.trees, type="response")
    test_preds <- predict.gbm(model, testing_set, n.trees=model$gbm.call$best.trees, type='response') ## these are the predicted values from the gbm at the points held out as testing set
  }else if (modelMethod == 'MARS'){
    prediction <- predict(pred, model, type='response')
    test_preds <- predict(model, testingSet, type='response')
  }else if (modelMethod == 'SVM'){
    prediction <- predict(pred, model, type='response')
    test_preds <- predict(model, testingSet, type='response')
  }else if (modelMethod == 'GAM'){
    prediction <- predict(pred, model, type='response')
    test_preds <- predict(model, testingSet, type='response')
  }
  predEnd <- proc.time()
  predTime <- predEnd - predStart

  ####*******Evaluate the Model ******######
  accStart <- proc.time()
  if(plot_prediction){
    plot(prediction)
  }
  
  test_real <- as.vector(testing_set['presence']) ## these are pre-thresholded 'real' values of testing set coordinates
  test_real <- t(test_real) ## transpose so its a row vector

  ##experiment with optimal thresholding
  if (presence_threshold == 'auto'){
    opt_threshold <- optim.thresh(test_real, test_preds)
    presence_threshold = opt_threshold[[presence_threshold.method]]
    presence_threshold = mean(presence_threshold)
  }

  confusion_matrix <- confusion.matrix(test_real, test_preds, presence_threshold)

  acc <- accuracy(test_real, test_preds, presence_threshold) ## calculate accuracy statistics
  accThreshold <- acc$threshold
  accAUC <- acc$AUC
  accOmmissionRate <- acc$omission.rate
  accSensitivity <- acc$sensitivity
  accSpecificity <- acc$specificity
  accPropCorrect <- acc$prop.correct
  accKappa <- acc$Kappa

  ## model fitting statistics that might be useful to keep
  if (modelMethod == 'GBM-BRT'){
    cvDeviance.mean <- model$cv.statistics$deviance.mean
    cvDeviance.se <- model$cv.statistics$deviance.se
    cvCorrelation.mean <- model$cv.statistics$correlation.mean
    cvCorrelation.se <- model$cv.statistics$correlation.se
    cvRoc.mean <- model$cv.statistics$discrimination.mean
    cvRoc.se <- model$cv.statistics$discrimination.se
    
    trainingResidualDeviance <- model$self.statistics$mean.resid
    trainingTotalDeviance <- model$self.statistics$mean.null
    trainingCorrelation <- model$self.statistics$correlation
    trainingRoc <- model$self.statistics$discrimination
    
    ntrees <- model$gbm.call$best.trees
  }else{
    cvDeviance.mean <- NULL
    cvDeviance.se <- NULL
    cvCorrelation.mean <- NULL
    cvCorrelation.se <- NULL
    cvRoc.mean <- NULL
    cvRoc.se <- NULL
    
    trainingResidualDeviance <- NULL
    trainingTotalDeviance <- NULL
    trainingCorrelation <- NULL
    trainingRoc <- NULL
    
    ntrees <- NULL
  }


  ## stop the timers
  accEnd <- proc.time()
  accTime <- accEnd - accStart
  endTime <- proc.time()
  totalTime <- endTime - startTime

  ## save the result
  if (save){
    fullPath = paste(saveLocation, "/", imgName, sep="")
    writeRaster(prediction, fullPath, overwrite=TRUE)
  }

  ## assemble the return vector

  r <- c(pollen_threshold, presence_threshold, totalTime['elapsed'], fitTime['elapsed'], predTime['elapsed'], accTime['elapsed'],
          accAUC, accOmmissionRate, accSensitivity, accSpecificity, accPropCorrect, accKappa,
         ntrees, cvDeviance.mean, cvDeviance.se, cvCorrelation.mean, cvCorrelation.se, cvRoc.mean, cvRoc.se,
         trainingResidualDeviance, trainingTotalDeviance, trainingCorrelation, trainingRoc, Sys.time())
  return (r)
}## end timeSDM function

Run <- function(iterations){
  ## database stuff
  drv <- dbDriver("MySQL")
  con <- dbConnect(drv, host=hostname, username=username, password=password, dbname=dbname)
  thisSession <- startSession(con)[[1]]
  print(paste("Running session #", thisSession))
  system2("logger", args=paste("R-Process: Started Session #", thisSession))
  for (iter in 0:iterations){
    print(iter)
    ## get the next experiment
    nextExp <- getNextAvailableExperiment(con)
    if (nrow(nextExp) == 0){
      print("No valid experiments found.")
      break
    }
    runNextExperiment(nextExp, con, thisSession)
  }
  print(paste("Finished", iter, "iterations.  Cleaning up."))
  system2("logger", args=paste("Finished process.  Cleaning up..."))
  sql <- paste("UPDATE SessionsManager SET sessionEnd=current_timestamp, sessionStatus='CLOSED', tableLastUpdate=current_timestamp WHERE sessionID=", thisSession, sep="")
  dbSendQuery(con, sql)
}

## auto Run
Run(globals.numIters)

## stop the instance when we get a return from the Run command
if (globals.shutdownOnFinish){
  system("shutdown")
}else{
  system('echo "Finished running script"')
}
