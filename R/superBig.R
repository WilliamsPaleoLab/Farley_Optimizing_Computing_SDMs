install.packages(c("randomForest", "doMC", "foreach", "dismo", "raster", "gbm", "SDMTools", "RMySQL", "rgdal", "gam", "earth", "devtools"), repos='http://cran.mtu.edu/')
library(foreach)
library(raster)
library(dismo)
library(SDMTools)
library(parallel)
library(randomForest)
library(RMySQL)
library(devtools)
devtools::install_github("krlmlr/ulimit")
library(ulimit)
##Set memory limit to 6GB
## TODO: make this more programatically
memory_limit(size = 6000)

setwd("/home/rstudio")
source("thesis-scripts/R/config.R")

library(doMC)


predPath <- "thesis-scripts/data/predictors/standard_biovars/"

pred_1deg <- stack(paste(predPath, "1_deg/", "standard_biovars_1_deg_2100.tif", sep=""))
pred_05deg <- stack(paste(predPath, "0_5_deg/", "standard_biovars_0_5_deg_2100.tif", sep=""))
pred_025deg <- stack(paste(predPath, "0_25_deg/", "standard_biovars_0_25_deg_2100.tif", sep=""))
pred_0_1deg <- stack(paste(predPath, "0_1_deg/", "standard_biovars_0_1_deg_2100.tif", sep=""))

names(pred_1deg) <- c("bio2", "bio7", "bio8", "bio15", "bio18", "bio19")
names(pred_05deg) <- c("bio2", "bio7", "bio8", "bio15", "bio18", "bio19")
names(pred_025deg) <- c("bio2", "bio7", "bio8", "bio15", "bio18", "bio19")
names(pred_0_1deg) <- c("bio2", "bio7", "bio8", "bio15", "bio18", "bio19")


timeSDM<-function(MB, ncores, memory, nocc = nrow(points), sr, testingFrac = 0.2, plot_prediction=F, pollen_threshold='auto',
                  presence_threshold='auto', presence_threshold.method='maxKappa', percentField='pollenPercentage', 
                  save=FALSE, saveLocation='/home/rstudio/thesis-scripts/modelOutput', imgName="rasterOutput", rfTrees = 25000,
                  modelMethod='GBM-BRT'){
  
  startTime <- proc.time()
  
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
  
  training_set <- points ## use all the points here
  
  training_set <- na.omit(training_set)
  
  ####*******Train the Model ******######
  fitStart <- proc.time()
  model <- "NEW" ##overwrite
  if (modelMethod == 'GBM-BRT') {
    model <- gbm.step(training_set, gbm.y="presence", gbm.x= c("bio2", "bio7", "bio8", "bio15", "bio18", "bio19"),
                      tree.complexity=5, learning.rate=0.001, verbose=TRUE, silent=FALSE, 
                      max.trees=100000000000, plot.main=FALSE, plot.folds = FALSE)
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
  }else if (modelMethod == 'PRF'){#parallel random forest
    x <- as.matrix(training_set[c('bio2', 'bio7', 'bio8', 'bio15', 'bio18', 'bio19')])
    y <- training_set[['presence']]
    treesPerCore <- rfTrees / ncores
    model <- foreach(ntree=rep(treesPerCore, ncores), .combine=combine, .multicombine=TRUE,
                     .packages='randomForest') %dopar% {
                       randomForest(x, y, ntree=ntree, nodesize=15)}
  }else if (modelMethod == "SRF"){## sequential random forest
    x <- as.matrix(training_set[c('bio2', 'bio7', 'bio8', 'bio15', 'bio18', 'bio19')])
    y <- training_set[['presence']]
    treesPerCore <- rfTrees / ncores
    model <- foreach(ntree=rep(treesPerCore, ncores), .combine=combine, .multicombine=TRUE,
                     .packages='randomForest') %do% {
                       randomForest(x, y, ntree=ntree, nodesize=15)}
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

## GBM and RF
##250MB
timeSDM<-function(MB, ncores, memory, nocc, sr, testingFrac = 0.2, plot_prediction=F, pollen_threshold='auto',
                  presence_threshold='auto', presence_threshold.method='maxKappa', percentField='pollenPercentage', 
                  save=FALSE, saveLocation='/home/rstudio/thesis-scripts/modelOutput', imgName="rasterOutput", rfTrees = 25000,
                  modelMethod='GBM-BRT')

args = commandArgs(trailingOnly=TRUE)  
if (length(args) == 1){
  compMem = args[1]
}else{
  compMem = -1
}

con <- dbConnect(dbDriver("MySQL"), host='104.154.235.236', password = 'Thesis-Scripting123!', dbname='timeSDM', username='Scripting')
print("Finished setup phase of Rscript")
print("Downloading stuff from google storage")
points <- read.csv("https://storage.googleapis.com/thesis-1329/250_MB_testData.csv")
points <- points[1:1000, ]
print("Doing GBM")
gbm250 <- timeSDM(250, ncore, compMem, nrow(points), modelMethod='GBM-BRT')
print("Doing RF")
rf250 <- timeSDM(250, ncore, compMem, nrow(points), modelMethod='PRF', rfTrees = 6000)

dbSendQuery(paste("INSERT INTO SuperBig VALUES (DEFAULT, 250, ", compMem, ",", nrow(points), gbm250[3], gbm250[4], "GBM-BRT"))
dbSendQuery(paste("INSERT INTO SuperBig VALUES (DEFAULT, 250, ", compMem, ",", nrow(points), rf250[3], rf250[4], "PRF"))
# 
# points <- read.csv("https://storage.googleapis.com/thesis-1329/500_MB_testData.csv")
# gbm500 <- timeSDM(500, ncore, compMem, nrow(points), modelMethod='GBM-BRT')
# rf500 <- timeSDM(500, ncore, compMem, nrow(points), modelMethod='PRF', rfTrees = 6000)
# dbSendQuery(paste("INSERT INTO SuperBig VALUES (DEFAULT, 500, ", compMem, ",", nrow(points), gbm500[3], gbm500[4], "GBM-BRT"))
# dbSendQuery(paste("INSERT INTO SuperBig VALUES (DEFAULT, 500, ", compMem, ",", nrow(points), rf500[3], rf500[4], "PRF"))
# 
# points <- read.csv("https://storage.googleapis.com/thesis-1329/1_GB_testData.csv")
# gbm1000 <- timeSDM(1000, ncore, compMem, nrow(points), modelMethod='GBM-BRT')
# rf1000 <- timeSDM(1000, ncore, compMem, nrow(points), modelMethod='PRF', rfTrees = 6000)
# dbSendQuery(paste("INSERT INTO SuperBig VALUES (DEFAULT, 1000, ", compMem, ",", nrow(points), gbm1000[3], gbm1000[4], "GBM-BRT"))
# dbSendQuery(paste("INSERT INTO SuperBig VALUES (DEFAULT, 1000, ", compMem, ",", nrow(points), rf1000[3], rf1000[4], "PRF"))
# 
# points <- rbind(points, points)
# gbm2000 <- timeSDM(2000, ncore, compMem, nrow(points), modelMethod='GBM-BRT')
# rf2000 <- timeSDM(2000, ncore, compMem, nrow(points), modelMethod='PRF', rfTrees = 6000)
# dbSendQuery(paste("INSERT INTO SuperBig VALUES (DEFAULT, 2000, ", compMem, ",", nrow(points), gbm2000[3], gbm2000[4], "GBM-BRT"))
# dbSendQuery(paste("INSERT INTO SuperBig VALUES (DEFAULT, 2000, ", compMem, ",", nrow(points), rf2000[3], rf2000[4], "PRF"))
