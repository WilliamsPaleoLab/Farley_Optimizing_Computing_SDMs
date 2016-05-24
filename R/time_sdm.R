##install packages if not yet installed
install.packages('dismo', 'gbm', 'rgdal', 'raster', 'SDMTools', 'RMySQL', 'futile.logger')

 ## load external libraries
library(gbm) ## base pacakges for regression trees
library(dismo) ## SDM package --> boosted regression tree function
library(raster) ## for raster manipulation
library(SDMTools) ## for accuracy assessment
library(RMySQL) ## for database communication
library(futile.logger) ## for logging to file
library(rgdal)

## get system details
systemVars <- Sys.info()
os <- systemVars['sysname'][[1]]
osRelease <- systemVars['release'][[1]]
osVersion <- systemVars['version'][[1]]
nodeName <- systemVars['nodename'][[1]]
machineArch <- systemVars['machine'][[1]]
loginName <- systemVars['login'][[1]]
gui <- .Platform$GUI
rArch <- .Platform$r_arch
r <- R.Version()
rVersion <- r$version.string
rPlatform <- r$platform
rName <- r$nickname
nCores <- detectCores()
platString <- paste(os, osRelease, osVersion, nodeName, machineArch)

set.seed(1)


## initialization
globals.ncores = nCores
globals.memory = -1
globals.nreps = 10
globals.noccOpts = c(50, 500, 1000, 10000)
globals.srOpts = c(1, 0.5, 0.25, 0.1)
globals.speciesOpts = c('betula', 'quercus', 'picea', 'tsuga')


##database utils
dbDisconnectAll <- function(){ # close all active connections
  lapply( dbListConnections(MySQL()), function(x) dbDisconnect(x) )
}

oqc <- function(sql){ ##open, query, close --> hack because I can't increase the timeout on the server 
  con <- dbConnect(MySQL(), host=hostname, dbname=dbname, user=username, password=password)
  result <- dbGetQuery(con, sql)
  dbDisconnectAll()
  return (result)
}

## set up logging to file and database
## lgoging writes messages to disk, 
## database records to remote mysql results

##logger
flog.logger("logger", DEBUG, appender=appender.file("C:/Users/student/Desktop/Scott/thesis-scripts/logs/testing.log"))
flog.info("Starting script on %s", platString, name='logger')


## database
## load the database params
source("C:/Users/student/Desktop/Scott/thesis-scripts/R/config.R")
flog.info("Loaded db config.", name='logger')
##insert a new session 
sql <- paste("INSERT INTO Sessions values (DEFAULT, '", os, "','", osRelease, "','", osVersion, "','", nodeName, "','", machineArch, "','", loginName, "','", loginName, "','", rArch, "','", rVersion, "','", rName, "','", rPlatform, "', DEFAULT, DEFAULT, 0, 0);", sep="")
oqc(sql)

## get the inserted ID
sql <- "SELECT max(sessionID) FROM Sessions;"
sessionID <- oqc(sql)[[1]]



## define a database connection

## predictor rasters
## HADGem 2100 monthly averages
## bioclimatic vars 2, 7, 8, 15, 18, 19
predPath <- "C:/Users/student/Desktop/Scott/thesis-scripts/data/predictors/standard_biovars/"

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
occPath <- "C:/Users/student/Desktop/Scott/thesis-scripts/data/occurrences/"
quercus_points <- read.csv(paste(occPath, "quercus_ready.csv", sep=""))
betula_points <- read.csv(paste(occPath, "betula_ready.csv", sep=""))
tsuga_points <- read.csv(paste(occPath, "tsuga_ready.csv", sep=""))
picea_points <- read.csv(paste(occPath, "picea_ready.csv", sep=""))
sequoia_points <- read.csv(paste(occPath, "sequoia_ready.csv", sep=""))

timeSDM<-function(species, ncores, memory, nocc, sr, testingFrac = 0.2, plot_prediction=F, pollen_threshold='auto', 
presence_threshold='auto', presence_threshold.method='maxKappa', percentField='pollenPercentage'){
  startTime <- proc.time()
  ## get the right species points
  if (species == "sequoia"){
    points <- sequoia_points
  }else if (species == 'quercus'){
    points <- quercus_points
  }else if (species == "betula"){
    points <- betula_points
  }else if (species == "tsuga"){
    points<- tsuga_points
  }else if (species == "picea"){
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
  model <- gbm.step(training_set, gbm.y="presence", gbm.x= c("bio2", "bio7", "bio8", "bio15", "bio18", "bio19"),
                    tree.complexity=5, learning.rate=0.001, verbose=FALSE, silent=TRUE, max.trees=100000000000)
  if (is.null(model)){
    stop("Got null model.")
  }
  fitEnd <- proc.time()
  fitTime <- fitEnd - fitStart


  ####*******Train the Model ******######
  predStart <- proc.time()
  prediction <-predict(pred, model, n.trees=model$gbm.call$best.trees, type="response")
  predEnd <- proc.time()
  predTime <- predEnd - predStart
  
  ####*******Evaluate the Model ******######
  accStart <- proc.time()
  if(plot_prediction){
    plot(prediction)
  }

  
  test_preds <- predict.gbm(model, testing_set, n.trees=model$gbm.call$best.trees, type='response') ## these are the predicted values from the gbm at the points held out as testing set
  test_real <- as.vector(testing_set['presence']) ## these are pre-thresholded 'real' values of testing set coordiantes
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
  
  ## stop the timers
  accEnd <- proc.time()
  accTime <- accEnd - accStart
  endTime <- proc.time()
  totalTime <- endTime - startTime
  ## assemble the return vector
  
  r <- c(species, ncores, memory, sr, nocc, pollen_threshold, presence_threshold, totalTime['elapsed'], fitTime['elapsed'], predTime['elapsed'], accTime['elapsed'],
         accThreshold, accAUC, accOmmissionRate, accSensitivity, accSpecificity, accPropCorrect, accKappa,
         ntrees, cvDeviance.mean, cvDeviance.se, cvCorrelation.mean, cvCorrelation.se, cvRoc.mean, cvRoc.se,
         trainingResidualDeviance, trainingTotalDeviance, trainingCorrelation, trainingRoc, Sys.time())
  return (r) 
}## end timeSDM function

ModelMaster <- function(){
  ## will run all combinations of species, nocc, sr and reps for a combination of cores and memory
  df <- list()
  rownames <- c("Species", "Cores", "Memory", "SpatialResolution", "NumOccurrences", "pollenThreshold", "presenceThreshold", "TotalTime", "fitTime", "predTime", "accTime", 
                "accThreshold", 
                "AUC", "ommission.rate", "sensitivity", "specificty", "prop.correct", "Kappa", 
                'NumTrees', 'meanCVDeviance', 'seCVDeviance', 'meanCVCorrelation', 'seCVCorrelation', 'meanCVRoc', 'seCVRoc', 'trainingResidualDeviance', 'trainingMeanDeviance',
                'trainingCorrelation', 'trainingROC', "Timestamp")
  flog.info("Loaded model master.", name='logger')
  cells = 1
  reps = 1
  for (taxon in globals.speciesOpts){
    for (no in globals.noccOpts){ ## number of training examples 
      for (sr in globals.srOpts){ ## spatial resolution
        cells = cells + 1
        for (n in 1:globals.nreps){ ## these are the individual repeitions
          ## get the experiment id from the experiments table in the database
          ## make sure it is not currently in progress --> select only 'QUEUED' experiments
          sql <- paste("SELECT cellNumber FROM Experiments  WHERE taxon='", taxon, "' AND spatialResolution=", sr , " AND numOccurrences=" , no , " AND replicateNumber=",
                       n, " AND Cores=", globals.ncores, " AND memory=", globals.memory, " AND runStatus='QUEUED';", sep="")
          thisID <- oqc(sql)
          ## see if we got results back
          if (nrow(thisID) == 0){
            flog.info("Found no matching experiments. Proceeding...")
            next
          }
          ## get the experiment numbers
          cellID = thisID['cellNumber']
          idString = paste(cellID, n, sep=".")
          
          
          flog.info("Running cell: %s, replicate #%s ***%s***", cellID, n, idString, name='logger')
          flog.info("Running %s  Cell Params: Cores: %s, Memory: %s, Taxon: %s, SR: %s, NO: %s", idString, globals.ncores, globals.memory, taxon, sr, no)
          sql <- paste("UPDATE Experiments SET runSession=", sessionID, ", runStatus='STARTED, lastUpdated=DEFAULT WHERE experimentID=", idString, ";", sep="")
          oqc(sql)
          errorMessage = FALSE
          ######
          #**
          #**
          res <- tryCatch(timeSDM(taxon, globals.ncores, globals.memory,no, sr),  ##this is the run here
                          error=function(e){ ## catch if the run raises an error
                            errorMessage = TRUE
                            flog.error(e, name='logger')
                            print(e)
                            return(c(FALSE))
          }) ## do the run
          #**
          #**
          if (res[1] == FALSE){
            print("ADVANCING")
            flog.error('Caught error. Advancing...')
            flog.error('Passing error.', name='logger')
            flog.fatal("Run %s Errored. Proceeding to next replicate.", idString)
            flog.info("Cell %s Replicate %s: ERROR", cellID, n, name='logger') ## to file
            sql <- paste("UPDATE Experiments SET runStatus='ERROR', lastUpdated=DEFAULT WHERE cellNumber=", cellID, " AND replicateNumber=", n, ";", sep="") 
            oqc(sql)
            next
          }

          ## and set the run to finished
            sql <- paste("UPDATE Experiments SET runStatus='DONE', lastUpdated=DEFAULT WHERE cellNumber=", cellID, " AND replicateNumber=", n, ";", sep="")  
            oqc(sql)
            ## put the results into the database
            sql <- paste("INSERT INTO Results VALUES (DEFAULT, ", cellID, ",", n, ",'", idString, "','", res[1], "',", res[2], ",", res[3], ",",
                         res[4], ",", res[5], ",", res[6], ",", res[7], ",", res[8], ",", res[9], ",", res[10], ",", res[11], ",",
                         res[12], ",", res[13], ",", res[14], ",", res[15], ",", res[16], ",", res[17], ",", res[18], ",", res[19],",",
                         res[20], ",", res[21], ",", res[22], ",", res[23], ",", res[24], ",", res[25], ",", res[26], ",", res[27],",",
                         res[28], ", DEFAULT);", sep="")
            oqc(sql)
            flog.info("Running time was %s", res[8])
            flog.info("Cell %s Replicate %s: DONE", cellID, n, name='logger') ## to file
            flog.info("Cell %s Replicate %s: DONE", cellID, n) ## to screen
            ## do results stuff
            df[[reps]] <- res ## append to the results vector
          reps = reps + 1
        }
      }
    }
  }
  ## sign off the session
  sql <- paste("UPDATE Sessions SET sessionEnd=DEFAULT, cellsRun=", cells, ", repsRun=", reps, " WHERE sessionID=", sessionID, sep="")
  oqc(sql)
  
  df <- t(data.frame(df))
  colnames(df) <- rownames
  View(df)
  write.csv(df, "C:/Users/student/Desktop/Scott/thesis-scripts/data/output/dry_run.csv")
}


