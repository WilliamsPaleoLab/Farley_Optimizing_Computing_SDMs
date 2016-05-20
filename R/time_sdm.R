library(dismo)
library(raster)
library(SDMTools)
## initialization
globals.ncores = Inf
globals.memory = Inf
globals.nreps = 2
globals.noccOpts = c(50, 75, 100, 200, 500)
globals.srOpts = c(1, 0.5, 0.25, 0.1)
globals.speciesOpts = c("sequoia")

## predictor rasters
## HADGem 2100 monthly averages
## bioclimatic vars 2, 7, 8, 15, 18, 19
predPath <- "C://Users/willlab/documents/Scott/thesis-scripts/data/predictors/standard_biovars/"

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
occPath <- "C://Users/willlab/documents/Scott/thesis-scripts/data/occurrences/"
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
  
  
  ####*******Train the Model ******######
  fitStart <- proc.time()
  model <- gbm.step(training_set, gbm.y="presence", gbm.x= c("bio2", "bio7", "bio8", "bio15", "bio18", "bio19"),
                    tree.complexity=5, learning.rate=0.001, verbose=FALSE, silent=TRUE)
  fitEnd <- proc.time()
  fitTime <- fitEnd - fitStart

  ####*******Train the Model ******######
  predStart <- proc.time()
  prediction <- predict(pred, model, n.trees=model$gbm.call$best.trees, type="response")
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
  
  print("Got to here 124")
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
}

ModelMaster <- function(cores, memory){
  ## will run all combinations of species, nocc, sr and reps for a combination of cores and memory
  df <- list()
  rownames <- c("Species", "Cores", "Memory", "SpatialResolution", "NumOccurrences", "pollenThreshold", "presenceThreshold", "TotalTime", "fitTime", "predTime", "accTime", 
                "accThreshold", 
                "AUC", "ommission.rate", "sensitivity", "specificty", "prop.correct", "Kappa", 
                'NumTrees', 'meanCVDeviance', 'seCVDeviance', 'meanCVCorrelation', 'seCVCorrelation', 'meanCVRoc', 'seCVRoc', 'trainingResidualDeviance', 'trainingMeanDeviance',
                'trainingCorrelation', 'trainingROC', "Timestamp")
  expID = 1
  for (no in globals.noccOpts){ ## number of training examples 
    for (sr in globals.srOpts){ ## spatial resolution
      for (n in 1:globals.nreps){ ## these are the individual repeitions
        res <- timeSDM("sequoia", globals.ncores, globals.memory,no, sr)
        df[[expID]] <- res
        print(expID)
        expID = expID + 1
      }
    }
  }


  df <- t(data.frame(df))
  colnames(df) <- rownames
  View(df)
  write.csv(df, "C://Users/willlab/documents/Scott/thesis-scripts/data/output/dry_run.csv")
}


