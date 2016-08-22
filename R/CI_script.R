con <- dbConnect(dbDriver("MySQL"), host='104.154.235.236', password = 'Thesis-Scripting123!', dbname='timeSDM', username='Scripting')
## get results from database
r <- dbGetQuery(con, "Select * From Experiments Inner Join Results on Results.experimentID = Experiments.experimentID WHERE experimentStatus = 'DONE' AND cores < 8 AND not model = 'SVM' and trainingExamples = 50 or trainingExamples = 100 or trainingExamples = 500 or trainingExamples = 1000;")
## separate models
r.brt <- r[which(r$model == 'GBM-BRT'), ]
r.gam <- r[which(r$model == 'GAM'), ]
r.mars <- r[which(r$model == 'MARS'), ]
f <- as.formula(totalTime ~ cores + GBMemory + (cores * GBMemory) + trainingExamples + spatialResolution)
## build testing and training set
s
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
cor(r.brt.brt.predict, r.brt.testing$totalTime)
cor(r.gam.brt.predict, r.gam.testing$totalTime)
cor(r.mars.brt.predict, r.mars.testing$totalTime)

r.brt.brt.delta <- r.brt.brt.predict - r.brt.testing$totalTime
r.gam.brt.delta <- r.gam.brt.predict - r.gam.testing$totalTime
r.mars.brt.delta <- r.mars.brt.predict - r.mars.testing$totalTime

mean(r.brt.brt.delta)
mean(r.gam.brt.delta)
mean(r.mars.brt.delta)

sd(r.brt.brt.delta)
sd(r.gam.brt.delta)
sd(r.mars.brt.delta)

plot(r.brt.brt.predict ~ r.brt.testing$totalTime, main='Performance Model (GBM)', xlab='Observed Execution Time [Seconds]', ylab='Predicted Execution Time [Seconds]', xlim=c(-10, 175), ylim=c(-10, 175), pch=3, col='darkgreen')
points(r.gam.brt.predict ~ r.gam.testing$totalTime, pch=3, col='darkred')
points(r.mars.brt.predict ~ r.mars.testing$totalTime, pch=3, col='dodgerblue')
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

r.brt.lm.delta <- r.brt.lm.predict - r.brt.testing$totalTime
r.gam.lm.delta <- r.gam.lm.predict - r.gam.testing$totalTime
r.mars.lm.delta <- r.mars.brt.predict - r.mars.testing$totalTime

mean(r.brt.lm.delta)
mean(r.gam.lm.delta)
mean(r.mars.lm.delta)

sd(r.brt.lm.delta)
sd(r.gam.lm.delta)
sd(r.mars.lm.delta)


plot(r.brt.lm.predict ~ r.brt.testing$totalTime, main='Performance Model (Linear Model)', xlab='Observed Execution Time [Seconds]', ylab='Predicted Execution Time [Seconds]', xlim=c(-10, 175), ylim=c(-10, 175), pch=3, col='darkgreen')
points(r.gam.lm.predict ~ r.gam.testing$totalTime, pch=3, col='darkred')
points(r.mars.lm.predict ~ r.mars.testing$totalTime, pch=3, col='dodgerblue')
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
