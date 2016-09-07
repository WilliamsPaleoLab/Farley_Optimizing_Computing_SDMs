library(foreach)
library(raster)
library(dismo)
library(SDMTools)
library(parallel)
library(randomForest)
library(RMySQL)
library(gbm)

setwd("/users/scottsfarley/documents")
source("thesis-scripts/R/config.R")

library(doMC)
library('caret')sudo supervisotctl


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
                  modelMethod='GBM-BRT', learning.rate=0.001, tree.complexity=5){
  
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
                      tree.complexity=tree.complexity, learning.rate=learning.rate, verbose=FALSE, silent=TRUE, 
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
    model <- foreach(ntree=rep(rfTrees, ncores), .combine=combine, .multicombine=TRUE,
                     .packages='randomForest') %dopar% {
                       randomForest(x, y, ntree=ntree)}
  }else if (modelMethod == "SRF"){## sequential random forest
    x <- as.matrix(training_set[c('bio2', 'bio7', 'bio8', 'bio15', 'bio18', 'bio19')])
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

tcSeq <- seq(from=1, to=5, by=1)
lrSeq <- c(0.005, 0.001, 0.005, 0.01, 0.05, 0.1, 0.25, 0.5, 1)
TexSeq <- seq(from=1000, to=11000, b = 5000)

for (lr in lrSeq){
  for(tc in tcSeq){
    for(tex in TexSeq){
      for(rep in 1:3){
        print(paste("This is replicate #", rep, "using", tex, "trainingExamples and a learning rate of",lr,"and a complexity of", tc))
        s <- timeSDM("Picea", detectCores(), -1, tex, 0.5, modelMethod="GBM-BRT", learning.rate=lr, tree.complexity=tc)
        sql <- paste("INSERT INTO GBMParameterRuns VALUES (DEFAULT,",
                      detectCores(), ",",
                      -1, ",",
                      "'Picea'", ",",
                      0.5, ",",
                      tex, ",",
                      tc, ",",
                      lr, ",",
                      s[3], "," , ## totalTime
                      s[4], "," , ##fit time
                      s[6], "," , ## acc time
                      s[5], "," , #predictTime
                      s[7], "," ,"DEFAULT);" ##AUC
        )
        dbSendQuery(con, sql) ## results query
      }
    }
  }
}

system("shutdown")
