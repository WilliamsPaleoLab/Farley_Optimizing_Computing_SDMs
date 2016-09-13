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


### plot speedup and efficiency
library(plyr)
res$grp <- interaction(res$method, res$cores, res$trainingExamples, res$numTrees)
resSum <-ddply(res, .(cores, trainingExamples, numTrees, method), summarize, meanTotalTime = mean(totalTime)) 

resSum$grp <- as.factor(interaction(resSum$trainingExamples, resSum$numTrees, resSum$cores))

resSplit <- split(resSum, resSum$grp)

parResults <- data.frame(cores = vector('numeric', length=length(resSplit)),
                      trainingExamples = vector('numeric', length=length(resSplit)),
                      numTrees = vector('numeric', length=length(resSplit)),
                      speedup = vector('numeric', length=length(resSplit)),
                      efficiency = vector('numeric', length=length(resSplit)))
for (i in 1:length(resSplit)){
  item <- resSplit[[i]]
  par <- item[1,]
  ser <- item[2, ]
  ncores <- par$cores
  Tex <- par$trainingExamples
  nt <- par$numTrees
  speedup <- ser$meanTotalTime / par$meanTotalTime
  eff <- ser$meanTotalTime / par$meanTotalTime /  ncores
  v <- c(ncores, Tex, nt, speedup, eff)
  parResults[i, ] <- v
}


##plot speedup
ggplot(parResults, aes(x = cores, y=speedup, 
                       group=interaction(trainingExamples, numTrees),
                       col = interaction(trainingExamples, numTrees))) + 
  geom_line() + ggtitle("Parallel Speedup of Random Forests")

## and efficiency
ggplot(parResults, aes(x = cores, y=efficiency, 
                       group=interaction(trainingExamples, numTrees),
                       col = interaction(trainingExamples, numTrees))) + 
  geom_line() + ggtitle("Parallel Efficiency of Random Forests")




