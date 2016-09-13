## Optimal Configuration Estimation
prices <- read.csv("/users/scottsfarley/documents/thesis-scripts/data/costs.csv")

## build off the CI script to get the model done
library(gbm)
library(plyr)
con <- dbConnect(dbDriver("MySQL"), host='104.154.235.236', password = 'Thesis-Scripting123!', dbname='timeSDM', username='Scripting')
## get results from database
r <- dbGetQuery(con, "Select * From Experiments Inner Join Results on Results.experimentID = Experiments.experimentID
                WHERE experimentStatus = 'DONE' AND model = 'GBM-BRT' OR model='MARS' OR model='GAM';")
## separate models
r.brt <- r[which(r$model == 'GBM-BRT'), ]
r.gam <- r[which(r$model == 'GAM'), ]
r.mars <- r[which(r$model == 'MARS'), ]
f <- as.formula(log(totalTime) ~ cores + GBMemory + (cores * GBMemory) + trainingExamples + spatialResolution)
## build testing and training set
r.brt.testingInd <- sample(nrow(r.brt), 100)
r.brt.testing <- r.brt[r.brt.testingInd, ]
r.brt.training <- r.brt[-r.brt.testingInd, ]
r.gam.testingInd <- sample(nrow(r.gam), 100)
r.gam.testing <- r.gam[r.gam.testingInd, ]
r.gam.training <- r.gam[-r.gam.testingInd, ]
r.mars.testingInd <- sample(nrow(r.mars), 100)
r.mars.testing <- r.mars[r.mars.testingInd, ]
r.mars.training <- r.mars[-r.mars.testingInd, ]

## build the GBM models
library(gbm)
r.brt.brt <- gbm(f, data=r.brt.training, n.trees = 15000, bag.fraction = 0.75)
r.gam.brt <- gbm(f, data=r.gam.training, n.trees = 15000, bag.fraction = 0.75)
r.mars.brt <- gbm(f, data=r.mars.training, n.trees = 15000, bag.fraction = 0.75)

## predict the results
# find best iteration
r.brt.brt.bestIter <- gbm.perf(r.brt.brt)
r.gam.brt.bestIter <- gbm.perf(r.gam.brt)
r.mars.brt.bestIter <- gbm.perf(r.mars.brt)

r.brt.brt.predict = predict(r.brt.brt, r.brt.testing, n.trees = r.brt.brt.bestIter)
r.gam.brt.predict = predict(r.gam.brt, r.gam.testing, n.trees = r.gam.brt.bestIter)
r.mars.brt.predict = predict(r.mars.brt, r.mars.testing, n.trees = r.mars.brt.bestIter)

## evaluate the prediction
cor(r.brt.brt.predict, log(r.brt.testing$totalTime))
cor(r.gam.brt.predict, log(r.gam.testing$totalTime))
cor(r.mars.brt.predict, log(r.mars.testing$totalTime))

r.brt.brt.delta <- r.brt.brt.predict - log(r.brt.testing$totalTime)
r.gam.brt.delta <- r.gam.brt.predict - log(r.gam.testing$totalTime)
r.mars.brt.delta <- r.mars.brt.predict - log(r.mars.testing$totalTime)

mean(r.brt.brt.delta)
mean(r.gam.brt.delta)
mean(r.mars.brt.delta)

sd(r.brt.brt.delta)
sd(r.gam.brt.delta)
sd(r.mars.brt.delta)

plot(r.brt.brt.predict ~ log(r.brt.testing$totalTime), main='Performance Model (GBM)', xlab='Observed Execution Time [Seconds]', ylab='Predicted Execution Time [Seconds]', xlim=c(-10, 175), ylim=c(-10, 175), pch=3, col='darkgreen')
points(r.gam.brt.predict ~ log(r.gam.testing$totalTime), pch=3, col='darkred')
points(r.mars.brt.predict ~ log(r.mars.testing$totalTime), pch=3, col='dodgerblue')
legend('bottomright', c('GBM-BRT', 'GAM', 'MARS'), col=c('darkgreen', 'darkred', 'dodgerblue'), pch=3)
abline(0, 1)

## Build the linear models
r.brt.lm <- lm(f, data=r.brt.training)
r.gam.lm <- lm(f, data=r.gam.training)
r.mars.lm <- lm(f, data=r.mars.training)

## predict 
r.brt.lm.predict = predict(r.brt.lm, r.brt.testing)
r.gam.lm.predict = predict(r.gam.lm, r.gam.testing)
r.mars.lm.predict = predict(r.mars.lm, r.mars.testing)

## evaluate the prediction
cor(r.brt.lm.predict, r.brt.testing$totalTime)
cor(r.gam.lm.predict, r.gam.testing$totalTime)
cor(r.mars.lm.predict, r.mars.testing$totalTime)

r.brt.lm.delta <- r.brt.lm.predict - log(r.brt.testing$totalTime)
r.gam.lm.delta <- r.gam.lm.predict - log(r.gam.testing$totalTime)
r.mars.lm.delta <- r.mars.brt.predict - log(r.mars.testing$totalTime)

mean(r.brt.lm.delta)
mean(r.gam.lm.delta)
mean(r.mars.lm.delta)

sd(r.brt.lm.delta)
sd(r.gam.lm.delta)
sd(r.mars.lm.delta)


plot(r.brt.lm.predict ~ log(r.brt.testing$totalTime), main='Performance Model (Linear Model)', xlab='Observed Execution Time [Seconds]', ylab='Predicted Execution Time [Seconds]', xlim=c(-10, 175), ylim=c(-10, 175), pch=3, col='darkgreen')
points(r.gam.lm.predict ~ log(r.gam.testing$totalTime), pch=3, col='darkred')
points(r.mars.lm.predict ~ log(r.mars.testing$totalTime), pch=3, col='dodgerblue')
legend('bottomright', c('GBM-BRT', 'GAM', 'MARS'), col=c('darkgreen', 'darkred', 'dodgerblue'), pch=3)
abline(0, 1)


## build accuracy prediction
a <- dbGetQuery(con, "Select * From Experiments Inner Join Results on Results.experimentID = Experiments.experimentID WHERE experimentStatus = 'DONE' and experimentCategory = 'nSensitivity';")
a.testingInd = sample(nrow(a), 75)
a.testing <- a[a.testingInd, ]
a.training <- a[-a.testingInd, ]
a.gbm <- gbm(testingAUC ~ trainingExamples, data=a.training, n.trees = 15000)
a.gbm.bestIter <- gbm.perf(a.gbm)
a.gbm.predict <- predict(a.gbm, a.testing, n.trees = a.gbm.bestIter)
cor(a.gbm.predict, a.testing$testingAUC)
a.gbm.delta <- a.gbm.predict - a.testing$testingAUC
mean(a.gbm.delta)
a.s <- ddply(a, .(cores, GBMemory, trainingExamples, taxon, cellID, spatialResolution),summarise, var = var(testingAUC), sd=sd(testingAUC), mean=mean(testingAUC), median=median(testingAUC))

plot(a.gbm, n.trees=a.gbm.bestIter, main='AUC Accuracy of GBM-BRT SDM', xlim=c(0, 10000))
points(a.training$testingAUC ~ a.training$trainingExamples, col=rgb(0.5, 0.5, 0, 0.5))
#points(a.s$median ~ a.s$trainingExamples, col=rgb(0.5, 0.5, 0, 1))
legend('bottomright', c('Observed Values', 'Predictive Model'), col=c(rgb(0.5, 0.5, 0), 'black'), lty=c(NA, 1), pch=c(1, NA))


library(RMySQL)
library(ggplot2)
library(gbm)
library(randomForest)
con <- dbConnect(dbDriver("MySQL"), host='104.154.235.236', password = 'Thesis-Scripting123!', dbname='timeSDM', username='Scripting')
res <- dbGetQuery(con, "SELECT * FROM RandomForestRuns WHERE rfID > 1986;")


ggplot(res) +
  geom_smooth(aes(x=cores, y=totalTime, group=interaction(method, trainingExamples, numTrees))) +
  geom_boxplot(aes(x=cores, y=totalTime, group=interaction(method, cores), col=interaction(method, cores))) 

ggplot(res) +
  geom_smooth(aes(x=cores, y=totalTime, group=interaction(method, trainingExamples, numTrees), col=method))


res$method <- as.factor(res$method)


testingInd <- sample(nrow(res), 100)

trainingSet <- res[-testingInd,]
testingSet <- res[testingInd,]



## the formula
f <- as.formula(log(totalTime) ~ cores + trainingExamples + numTrees )


## build the linear model
rf.lm <- lm(f, data=trainingSet)

## predict on the testing set
rf.lm.pred <- predict(rf.lm, testingSet)

plot(rf.lm.pred ~ log(testingSet$totalTime), xlab="Observed Time",ylab="Modeled Time", main="Linear Execution Time Model")
abline(0, 1, col='red')
anova(rf.lm)

RSS.lm <- sum((rf.lm.pred - log(testingSet$totalTime))^2)

## develop the gbm model
rf.gbm <- gbm(f, data=trainingSet, n.trees = 15000, bag.fraction=0.75)




## Build the GBM model
rf.gbm <- gbm(f, data=trainingSet, n.trees = 30000, bag.fraction = 0.75)
rf.gbm.bestIter <- gbm.perf(rf.gbm)
rf.gbm.pred = predict(rf.gbm, testingSet, n.trees = rf.gbm.bestIter)

plot(rf.gbm.pred ~ log(testingSet$totalTime), xlab="Observed Time",ylab="Modeled Time", main="Linear Execution Time Model")
abline(0, 1, col='red')
summary(rf.gbm, rf.gbm.bestIter)

RSS.gbm <- sum((rf.gbm.pred - log(testingSet$totalTime))^2)


## build a random forest model for shits and gigs
rf.rf <- randomForest(f, data=trainingSet, ntree = 10000, localImp=T) # localImp gives ability to look at IncMSE
importance(rf.rf)

rf.rf.pred = predict(rf.rf, testingSet)

plot(rf.rf.pred ~ log(testingSet$totalTime), xlab="Observed Time",ylab="Modeled Time", main="Linear Execution Time Model")
abline(0, 1, col='red')

RSS.rf <- sum((rf.rf.pred - log(testingSet$totalTime))^2)

rf.rf.mean <- mean(rf.rf.pred - log(testingSet$totalTime))
rf.gbm.mean <- mean(rf.gbm.pred - log(testingSet$totalTime))
rf.lm.mean <- mean(rf.lm.pred - log(testingSet$totalTime))

rf.rf.sd <- sd(rf.rf.pred - log(testingSet$totalTime))
rf.gbm.sd <- sd(rf.gbm.pred - log(testingSet$totalTime))
rf.lm.sd <- sd(rf.lm.pred - log(testingSet$totalTime))



## build the accuracy model
f.acc <- as.formula(AUC ~ trainingExamples + numTrees + cores)
acc.lm <- lm(f.acc, data=trainingSet)

anova(acc.lm)

acc.lm.pred <- predict(acc.lm, testingSet)

plot(acc.lm.pred ~ testingSet$AUC, xlab="Observed Accuracy", ylab="Modeled Accuracy", main="Linear Accuracy Model")
abline(0, 1)
## note the high dependence on training examples in the ANOVA.  No other variables are significant
RSS.acc.lm <- sum((acc.lm.pred - testingSet$AUC)^2)
acc.lm.mean <- mean(acc.lm.pred - testingSet$AUC)
acc.lm.sd <- sd(acc.lm.pred - testingSet$AUC)


## gbm model
acc.gbm <- gbm(f.acc, data=trainingSet, n.trees = 15000, bag.fraction=0.75)
acc.gbm.bestIter <- gbm.perf(acc.gbm)

acc.gbm.pred <- predict(acc.gbm, testingSet, n.trees = acc.gbm.bestIter)

summary(acc.gbm, acc.gbm.bestIter)

plot(acc.gbm.pred ~ testingSet$AUC, xlab="Observed Accuracy", ylab="Modeled Accuracy", main="GBM Accuracy Model")
abline(0,1)

## it's surprising that numTrees gives so little information to the model. This suggests that users can pick the lowest number of trees, and still have a relatively accurate model
RSS.acc.gbm <- sum((acc.gbm.pred - testingSet$AUC)^2)
acc.gbm.mean <- mean(acc.gbm.pred - testingSet$AUC)
acc.gbm.sd <- sd(acc.gbm.pred - testingSet$AUC)

## and, the randomForest model
acc.rf <- randomForest(f.acc, data=trainingSet, ntree=15000, localImp = T)
acc.rf.pred <- predict(acc.rf, testingSet)
importance(acc.rf) ## adding number of trees actually gives negative information!?

plot(acc.rf.pred ~ testingSet$AUC, xlab="Observed Accuracy", ylab="Modeled Accuracy", main="GBM Accuracy Model")
abline(0,1)
RSS.acc.rf <- sum((acc.rf.pred - testingSet$AUC)^2)
acc.rf.mean <- mean(acc.rf.pred - testingSet$AUC)
acc.rf.sd <- sd(acc.rf.pred - testingSet$AUC)



library(reshape2)

estimateOptimal <- function(trainingExamples, spatialResolution, 
                            method, prices, rfTrees = 6000){
  
  timeAndCost <- data.frame(cores = vector('numeric', length=nrow(prices)),
                            GBMemory = vector('numeric', length=nrow(prices)),
                            seconds = vector('numeric', length=nrow(prices)),
                            cost = vector('numeric', length=nrow(prices)),
                            AUC = vector('numeric', length=nrow(prices)),
                            Conf = vector('numeric', length=nrow(prices)),
                            TrainingExamples = vector('numeric', length=nrow(prices)),
                            SpatialRes = vector('numeric', length=nrow(prices)))
  
  for (i in 1:nrow(prices)){
    thisComp <- prices[i,]
    thisComp.cores <- thisComp$CPUs
    thisComp.memory <- 1
    scenario <- c(cores = thisComp.cores, GBMemory = thisComp.memory, 
                  trainingExamples=trainingExamples, 
                  spatialResolution=spatialResolution, numTrees = rfTrees)
    scenario <- t(melt(scenario, data.frame))
    scenario <- as.data.frame(scenario)
    thisComp.price <- thisComp$TotalRate## this is rate per hour
    thisComp.pricePerSecond <- thisComp.price / 3600 ## this is rate per second
    thisComp.Conf <- thisComp$ConfigurationNumber
    if (method == 'GBM-BRT'){
      timeModel <- r.brt.lm
      timePred <- predict(timeModel, scenario, n.trees = r.brt.brt.bestIter)
      accModel <- a.gbm
      accPred <- predict(accModel, scenario, n.trees = a.gbm.bestIter)
    }else if(method == 'GAM'){
      timeModel <- r.gam.brt
      timePred <- predict(timeModel, scenario, n.trees = r.gam.brt.bestIter)
      accPred <- 0
    }else if (method == 'MARS'){
      timeModel <- r.mars.brt
      timePred <- predict(timeModel, scenario, n.trees = r.mars.brt.bestIter)
      accPred <- 0
    }else if(method == 'PRF'){
      timeModel <- rf.lm
      timePred <- predict(timeModel, scenario, n.trees = rf.gbm.bestIter)
      accModel <- acc.gbm
      accPred <- predict(accModel, scenario, n.tree = acc.gbm.bestIter)
    }else if(method == "SRF"){
      timeModel <- rf.gbm
      timePred <- predict(timeModel, scenario, n.trees = rf.gbm.bestIter)
      accModel <- acc.gbm
      accPred <- predict(accModel, scenario, n.tree = acc.gbm.bestIter)
    }else{
      stop("Not able to evaluate model.")
    }
    scenarioCost <- exp(timePred) * thisComp.pricePerSecond
    v <- c(thisComp.cores, thisComp.memory, exp(timePred), scenarioCost, accPred, thisComp.Conf, scenario$trainingExamples, scenario$spatialResolution)
    timeAndCost[i, ] <- v
  }
  euc.dist <- function(x1, x2) sqrt(sum((x1 - x2) ^ 2))
  
  
  return(timeAndCost)
}

o <- estimateOptimal(10000, 1, 'GBM-BRT', prices=prices)

x <- o[c("cost", "seconds")]

dists <- as.matrix(dist(x, method = "maximum"))[1,]
