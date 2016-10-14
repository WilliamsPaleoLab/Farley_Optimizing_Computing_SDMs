library(randomForest)
library(reshape2)
library(gam)
library(sensitivity)
library(ggplot2)
library(gbm)
setwd("/users/scottsfarley/documents")



## RANDOM FORESTS
res <- read.csv("thesis-scripts/data/rf_full.csv")
res$cores[res$method == "SERIAL"] = 1
res <- res[c("totalTime", 'fittingTime', 'predictionTime', "cores", "GBMemory", "trainingExamples", "numPredictors")]
res$cores <- as.numeric(res$cores)
res$totalTime <- as.numeric(res$totalTime)
res$GBMemory <- as.numeric(res$GBMemory)
res$trainingExamples <- as.numeric(res$trainingExamples)
res$numPredictors <- as.numeric(res$numPredictors)
predictors <- data.frame(scale(res[c("cores", "GBMemory", "trainingExamples", "numPredictors")]))
response <- log(res$totalTime)
rf.rf.sensModel <- randomForest(predictors, response, ntree=2500, mtry=4)
toTest <- predictors
samp1 <- toTest[sample(nrow(toTest), 10000, replace=T),]
samp2 <- toTest[sample(nrow(toTest), 10000, replace=T),]
sens <- sobol(rf.rf.sensModel, samp1, samp2, order=1, nboot=1000)
rf.sobol <- data.frame(sens$S)
rf.sobol$names <- rownames(rf.sobol)
ggplot(rf.sobol, aes(x = names)) + geom_point(aes(y=original)) +
  geom_errorbar(aes(ymax=max..c.i., ymin=min..c.i.)) +
  ylab("First Order Sobol' Index") +
  xlab("") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ggtitle("Random Forest Sensitivity Analysis")


rf.testingInd <- sample(nrow(res), nrow(res) * 0.2)
rf.testing <- res[rf.testingInd,]
rf.training <- res[-rf.testingInd,]
rf.training.predictors <- rf.training[c( "numPredictors", "cores", "GBMemory", "trainingExamples")]
rf.training.predictors <- data.frame(scale(rf.training.predictors))
rf.training.response <- log(rf.training[[c("fittingTime")]])
rf.rf <- randomForest(rf.training.predictors, rf.training.response, ntree = 15000, mtry=4)

## do prediction
rf.testing.predictors <- rf.testing[c( "numPredictors", "cores", "GBMemory", "trainingExamples")]
rf.testing.predictors <- data.frame(scale(rf.testing.predictors))
rf.prediction <- predict(rf.rf, rf.testing.predictors)
rf.prediction <- exp(rf.prediction)

## get statistics
rf.mdCor <- cor(rf.prediction, rf.testing[['fittingTime']])
rf.mdDelta <- rf.prediction - rf.testing$totalTime
rf.mdDelta.mean <- mean(rf.mdDelta)
rf.mdDelta.sd <- sd(rf.mdDelta)
rf.mdDelta.RSS <- sum((rf.prediction - rf.testing$totalTime)^2)

## Plot
plot(rf.prediction, rf.testing[['fittingTime']])
abline(0, 1)
plot(log(rf.prediction), log(rf.testing[['fittingTime']]))
abline(0, 1)


#### PredictionTimeModel
gams <- read.csv("thesis-scripts/data/gam_full.csv")
mars <- read.csv("thesis-scripts/data/mars_full.csv")
rfs <- read.csv("thesis-scripts/data/rf_full.csv")
gbms <- read.csv("thesis-scripts/data/gbm_all.csv")
spatRes <- rbind(gams[c("predictionTime", "numPredictors", "cells", "trainingExamples","cores", "GBMemory", "fittingTime")], 
      mars[c("predictionTime", "numPredictors", "cells", "trainingExamples","cores", "GBMemory","fittingTime")],
      rfs[c("predictionTime", "numPredictors", "cells", "trainingExamples","cores", "GBMemory","fittingTime")],
      gbms[c("predictionTime", "numPredictors", "cells", "trainingExamples","cores", "GBMemory","fittingTime")])

spatRes.testingInd <- sample(nrow(spatRes), 2500)
spatRes.testing <- spatRes[spatRes.testingInd,]
spatRes.training <- spatRes[-spatRes.testingInd,]

fTime <- log(as.numeric(spatRes.training[['fittingTime']]))
sTime <- log(spatRes.training[['predictionTime']])
fX <- spatRes.training[c("numPredictors", "cores", "trainingExamples", "GBMemory")]
fX$numPredictors <- as.numeric(fX$numPredictors)
fX$cores <- as.numeric(fX$cores)
fX$trainingExamples <- as.numeric(fX$trainingExamples)
fX$GBMemory <- as.numeric(fX$GBMemory)
sX <- spatRes.training[c("cells", "numPredictors", "trainingExamples")]
spatRes.rf <- randomForest(x, y, ntree=1000, mtry=3)

# spatRes.prediction <- predict(spatRes.rf, spatRes.testing)
# cor(log(spatRes.testing$predictionTime), spatRes.prediction)
# 


totalPrediction = predict(rf.rf, rf.testing) + predict(spatRes.rf, rf.testing)
plot(log(rf.testing$fittingTime + rf.testing$predictionTime))




####################################################################################
# ## GAMS
res <- read.csv("thesis-scripts/data/gam_full.csv")
res <- res[c("totalTime", "cores", "GBMemory", "trainingExamples", "numPredictors", "cells")]
res$cores <- as.numeric(res$cores)
res$totalTime <- as.numeric(res$totalTime)
res$GBMemory <- as.numeric(res$GBMemory)
res$trainingExamples <- as.numeric(res$trainingExamples)
res$numPredictors <- as.numeric(res$numPredictors)
res$cells <- as.numeric(res$cells)
predictors <- data.frame(scale(res[c("cores", "GBMemory", "trainingExamples", "numPredictors")]))
response <- log(res$totalTime)
gam.rf.sensModel <- randomForest(predictors, response, ntree=2500, mtry=4)
toTest <- predictors
samp1 <- toTest[sample(nrow(toTest), 400, replace=F),]
samp2 <- toTest[sample(nrow(toTest), 400, replace=F),]
sens <- sobol(gam.rf.sensModel, samp1, samp2, order=2, nboot=1000)
gam.sobol <- data.frame(sens$S)
gam.sobol$names <- rownames(gam.sobol)
ggplot(gam.sobol, aes(x = names)) + geom_point(aes(y=original)) +
  geom_errorbar(aes(ymax=max..c.i., ymin=min..c.i.)) +
  ylab("First Order Sobol' Index") +
  xlab("") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ggtitle("GAM Sensitivity Analysis")

gam.testingInd <- sample(nrow(res), nrow(res) * 0.2)
gam.testing <- res[gam.testingInd,]
gam.training <- res[-gam.testingInd,]
gam.training.predictors <- gam.training[c( "numPredictors", "cores", "GBMemory", "trainingExamples")]
gam.training.predictors <- data.frame(scale(gam.training.predictors))
gam.training.response <- log(gam.training[[c("totalTime")]])
gam.rf <- randomForest(gam.training.predictors, gam.training.response, ntree = 15000, mtry=4)

## do prediction
gam.testing.predictors <- gam.testing[c( "numPredictors", "cores", "GBMemory", "trainingExamples")]
gam.testing.predictors <- data.frame(scale(gam.testing.predictors))
gam.prediction <- predict(gam.rf, gam.testing.predictors)
gam.prediction <- exp(gam.prediction)

## get statistics
gam.mdCor <- cor(gam.prediction, gam.testing[['totalTime']])
gam.mdDelta <- gam.prediction - gam.testing$totalTime
gam.mdDelta.mean <- mean(gam.mdDelta)
gam.mdDelta.sd <- sd(gam.mdDelta)
gam.mdDelta.RSS <- sum((gam.prediction - gam.testing$totalTime)^2)

## Plot
plot(gam.prediction, gam.testing[['totalTime']])
abline(0, 1)
plot(log(gam.prediction), log(gam.testing[['totalTime']]))
abline(0, 1)









####################################################################################
## MARS
res <- read.csv("thesis-scripts/data/mars_full.csv")
res <- res[c("totalTime", "cores", "GBMemory", "trainingExamples", "numPredictors", "cells")]
res$cores <- as.numeric(res$cores)
res$totalTime <- as.numeric(res$totalTime)
res$GBMemory <- as.numeric(res$GBMemory)
res$trainingExamples <- as.numeric(res$trainingExamples)
res$numPredictors <- as.numeric(res$numPredictors)
res$cells <- as.numeric(res$cells)
predictors <- data.frame(scale(res[c("cores", "GBMemory", "trainingExamples", "numPredictors")]))
response <- log(res$totalTime)
mars.rf.sensModel <- randomForest(predictors, response, ntree=15000, mtry=4)
toTest <- predictors[c("cores", "GBMemory", "trainingExamples", "numPredictors")]
samp1 <- toTest[sample(nrow(toTest), 400, replace=F),]
samp2 <- toTest[sample(nrow(toTest), 400, replace=F),]
sens <- sobol(rf, samp1, samp2, order=2, nboot=1000)
mars.sobol <- data.frame(sens$S)
mars.sobol$names <- rownames(rf.sobol)
ggplot(mars.sobol, aes(x = names)) + geom_point(aes(y=original)) +
  geom_errorbar(aes(ymax=max..c.i., ymin=min..c.i.)) +
  ylab("First Order Sobol' Index") +
  xlab("") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ggtitle("MARS Sensitivity Analysis")

mars.testingInd <- sample(nrow(res), nrow(res) * 0.2)
mars.testing <- res[mars.testingInd,]
mars.training <- res[-mars.testingInd,]
mars.training.predictors <- mars.training[c( "numPredictors", "cores", "GBMemory", "trainingExamples")]
mars.training.predictors <- data.frame(scale(mars.training.predictors))
mars.training.response <- log(mars.training[[c("totalTime")]])
mars.rf <- randomForest(mars.training.predictors, mars.training.response, ntree = 15000, mtry=4)

## do prediction
mars.testing.predictors <- mars.testing[c( "numPredictors", "cores", "GBMemory", "trainingExamples")]
mars.testing.predictors <- data.frame(scale(mars.testing.predictors))
mars.prediction <- predict(mars.rf, mars.testing.predictors)
mars.prediction <- exp(mars.prediction)

## get statistics
mars.mdCor <- cor(mars.prediction, mars.testing[['totalTime']])
mars.mdDelta <- mars.prediction - mars.testing$totalTime
mars.mdDelta.mean <- mean(mars.mdDelta)
mars.mdDelta.sd <- sd(mars.mdDelta)
mars.mdDelta.RSS <- sum((mars.prediction - mars.testing$totalTime)^2)

## Plot
plot(mars.prediction, mars.testing[['totalTime']])
abline(0, 1)
plot(log(mars.prediction), log(mars.testing[['totalTime']]))
abline(0, 1)




## GBM-BRT
res <- read.csv("thesis-scripts/data/gbm_all.csv")
res <- res[c("totalTime", "cores", "GBMemory", "trainingExamples", "numPredictors", "cells")]
res$cores <- as.numeric(res$cores)
res$totalTime <- as.numeric(res$totalTime)
res$GBMemory <- as.numeric(res$GBMemory)
res$trainingExamples <- as.numeric(res$trainingExamples)
res$numPredictors <- as.numeric(res$numPredictors)
res$cells <- as.numeric(res$cells)
predictors <- scale(res[c("cores", "GBMemory", "trainingExamples", "numPredictors", "cells")])
response <- log(res$totalTime)
gbm.rf.sensModel <- randomForest(predictors, response, ntree=2500, mtry=4)
toTest <- predictors
samp1 <- toTest[sample(nrow(toTest), 10000, replace=T),]
samp2 <- toTest[sample(nrow(toTest), 10000, replace=T),]
sens <- sobol(gbm.rf.sensModel, samp1, samp2, order=2, nboot=1000)
rf.sobol <- data.frame(sens$S)
rf.sobol$names <- rownames(rf.sobol)
ggplot(rf.sobol, aes(x = names)) + geom_point(aes(y=original)) +
  geom_errorbar(aes(ymax=max..c.i., ymin=min..c.i.)) +
  ylab("First Order Sobol' Index") +
  xlab("") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ggtitle("GBM-BRT Sensitivity Analysis")


gbm.testingInd <- sample(nrow(res), nrow(res) * 0.2)
gbm.testing <- res[gbm.testingInd,]
gbm.training <- res[-gbm.testingInd,]
gbm.training.predictors <- gbm.training[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
gbm.training.predictors <- data.frame(gbm.training.predictors)
gbm.training.response <- log(gbm.training[[c("totalTime")]])
gbm.rf <- randomForest(gbm.training.predictors, gbm.training.response, ntree = 1000, mtry=4)

## do prediction
gbm.testing.predictors <- gbm.testing[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
gbm.testing.predictors <- data.frame(scale(gbm.testing.predictors))
gbm.prediction <- predict(gbm.rf, gbm.testing.predictors)
gbm.prediction <- exp(gbm.prediction)

## get statistics
gbm.mdCor <- cor(gbm.prediction, gbm.testing[['totalTime']])
gbm.mdDelta <- gbm.prediction - gbm.testing$totalTime
gbm.mdDelta.mean <- mean(gbm.mdDelta)
gbm.mdDelta.sd <- sd(gbm.mdDelta)
gbm.mdDelta.RSS <- sum((gbm.prediction - gbm.testing$totalTime)^2)

## Plot
plot(gbm.prediction, log(gbm.testing[['totalTime']]))
abline(0, 1)
plot(log(gbm.prediction), gbm.testing[['totalTime']])
abline(0, 1)


prices <- read.csv("/users/scottsfarley/documents/thesis-scripts/data/costs.csv")

estimateOptimal <- function(trainingExamples, cells, numPredictors,
                            model, prices, rfTrees = 6000){
  
  timeAndCost <- data.frame(cores = vector('numeric', length=nrow(prices)),
                            GBMemory = vector('numeric', length=nrow(prices)),
                            seconds = vector('numeric', length=nrow(prices)),
                            cost = vector('numeric', length=nrow(prices)))
  
  for (i in 1:nrow(prices)){
    thisComp <- prices[i,]
    thisComp.cores <- thisComp$CPUs
    thisComp.memory <- 1
    scenario <- c(cores = thisComp.cores, GBMemory = thisComp.memory, 
                  trainingExamples=trainingExamples, 
                  numPredictors = numPredictors,
                  cells=cells)
    
    scenario <- t(melt(scenario, data.frame))
    scenario <- as.data.frame(scenario)
    thisComp.price <- thisComp$TotalRate## this is rate per hour
    thisComp.pricePerSecond <- thisComp.price / 3600 ## this is rate per second
    thisComp.Conf <- thisComp$ConfigurationNumber
    print(thisComp)
    if (model == 'GBM-BRT'){
      logTime <- predict(gbm.rf, scenario)
    }
    timePred <- exp(logTime)
    scenarioCost <- exp(timePred) * thisComp.pricePerSecond
    v <- c(thisComp.cores, thisComp.memory, timePred, scenarioCost)
    print(v)
    timeAndCost[i, ] <- v
  }
  euc.dist <- function(x1, x2) sqrt(sum((x1 - x2) ^ 2))
  return(timeAndCost)
}

estimateOptimal(trainingExamples = 1000, numPredictors = 5, cells=15000, model='GBM-BRT', prices=prices)





