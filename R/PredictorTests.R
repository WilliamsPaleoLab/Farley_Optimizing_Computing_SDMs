install.packages(c("randomForest", "doMC", "foreach", "dismo", "raster", "gbm", "SDMTools", "RMySQL", "rgdal", "gam", "earth"), repos='http://cran.mtu.edu/')
library(foreach)
library(raster)
library(dismo)
library(SDMTools)
library(parallel)
library(randomForest)
library(RMySQL)
library(gbm)

setwd("/home/rstudio")

source("thesis-scripts/R/config.R")

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
                  save=FALSE, saveLocation='/home/rstudio/thesis-scripts/modelOutput', imgName="rasterOutput", rfTrees = 25000,
                  modelMethod='GBM-BRT', numPredictors = 5){
  
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
    print("Doing GBM model.")
    predictors <- c("bio2", "bio7", "bio8", "bio15", "bio18", "bio19")[1:numPredictors]
    print(predictors)
    model <- gbm.step(training_set, gbm.y="presence", gbm.x= predictors,
                      tree.complexity=5, learning.rate=0.001, verbose=FALSE, silent=TRUE, 
                      max.trees=100000000000, plot.main=FALSE, plot.folds = FALSE)
  }else if (modelMethod == 'MARS'){
    x <- training_set[c('bio2', 'bio7', 'bio8', 'bio15', 'bio18', 'bio19', 'presence')]
    if (numPredictors == 1){
      f = as.formula(paste('presence ~ ', paste('bio2', sep=' + ')))
    }else if (numPredictors == 2){
      f = as.formula(paste('presence ~ ', paste('bio2', 'bio7', sep=' + ')))
    }else if (numPredictors == 3){
      f = as.formula(paste('presence ~ ', paste('bio2', 'bio7', 'bio8',  sep=' + ')))
    }else if (numPredictors == 4){
      f = as.formula(paste('presence ~ ', paste('bio2', 'bio7', 'bio8', 'bio15', 'bio18', sep=' + ')))
    }else{
      f = as.formula(paste('presence ~ ', paste('bio2', 'bio7', 'bio8', 'bio15', 'bio18', 'bio19', sep=' + ')))
    }
    model <- earth(f, data=x)
    print(summary(model))
  }else if (modelMethod == 'SVM'){
    # x <- training_set[c('bio2', 'bio7', 'bio8', 'bio15', 'bio18', 'bio19', 'presence')]
    # f = as.formula(paste('presence ~ ', paste('bio2', 'bio7', 'bio8', 'bio15', 'bio18', 'bio19', sep=' + ')))
    # model <- svm(f, data=x)
  }else if (modelMethod == 'GAM'){
    x <- training_set[c('bio2', 'bio7', 'bio8', 'bio15', 'bio18', 'bio19', 'presence')]
    if (numPredictors == 1){
      f = as.formula(paste('presence ~ ', paste('bio2', sep=' + ')))
    }else if (numPredictors == 2){
      f = as.formula(paste('presence ~ ', paste('bio2', 'bio7', sep=' + ')))
    }else if (numPredictors == 3){
      f = as.formula(paste('presence ~ ', paste('bio2', 'bio7', 'bio8',  sep=' + ')))
    }else if (numPredictors == 4){
      f = as.formula(paste('presence ~ ', paste('bio2', 'bio7', 'bio8', 'bio15', 'bio18', sep=' + ')))
    }else{
      f = as.formula(paste('presence ~ ', paste('bio2', 'bio7', 'bio8', 'bio15', 'bio18', 'bio19', sep=' + ')))
    }
    model <- gam(f, data=x)
    print(summary(model))
  }else if (modelMethod == 'PRF'){#parallel random forest
    x <- as.matrix(training_set[c('bio2', 'bio7', 'bio8', 'bio15', 'bio18', 'bio19')])
    y <- training_set[['presence']]
    model <- foreach(ntree=rep(rfTrees, ncores), .combine=combine, .multicombine=TRUE,
                     .packages='randomForest') %dopar% {
                       randomForest(x, y, ntree=ntree)}
  }else if (modelMethod == "SRF"){## sequential random forest
    predictors <- c("bio2", "bio7", "bio8", "bio15", "bio18", "bio19")[1:numPredictors]
    print(predictors)
    x <- as.matrix(training_set[predictors])
    y <- training_set[['presence']]
    model <- foreach(ntree=rep(rfTrees, ncores), .combine=combine, .multicombine=TRUE,
                     .packages='randomForest') %do% {
                       randomForest(x, y, ntree=ntree)}
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
  }else if (modelMethod == 'PRF'){
    prediction <- predict(pred, model, type='response')
    test_preds <- predict(model, testing_set, type='response')
  }else if (modelMethod == 'SRF'){
    prediction <- predict(pred, model, type='response')
    test_preds <- predict(model, testing_set, type='response')
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

drv <- dbDriver("MySQL")
con <- dbConnect(drv, host=hostname, username=username, password=password, dbname=dbname)


numExamples <- 6000
for (rep in 1:5){
  for (p in 1:5){
    for (n in seq(1000, 11000, by=1000)){
      gamRes <- timeSDM("Picea", detectCores(), -1, n, 0.5, modelMethod="GAM", numPredictors = p)
      marsRes <- timeSDM("Picea", detectCores(), -1, n, 0.5, modelMethod="MARS", numPredictors = p)
      gamSQL <- paste("INSERT INTO PredictorRuns VALUES (DEFAULT, 'GAM',",
                      gamRes[3], "," ,
                      gamRes[4], "," ,
                      gamRes[5], "," ,
                      gamRes[6], "," ,
                      gamRes[7], "," ,
                    n, ",",
                    0.5, ",",
                    p, ",DEFAULT);"
      )
      marsSQL <- paste("INSERT INTO PredictorRuns VALUES (DEFAULT, 'MARS',",
                     marsRes[3], "," ,
                     marsRes[4], "," ,
                     marsRes[5], "," ,
                     marsRes[6], "," ,
                     marsRes[7], "," ,
                      n, ",",
                      0.5, ",",
                      p, ",DEFAULT);"
      )
      dbSendQuery(con, gamSQL) ## results query
      dbSendQuery(con, marsSQL) ## results query
    }
  }
}

system("shutdown")
