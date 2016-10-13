# install.packages('rJava')
# install.packages('bartMachine')
# install.packages('matrixStats')
# install.packages('ggplot2')
library(ggplot2)
library(matrixStats)
options(java.parameters = "-Xmx50g") ## change memory allotment to RJava
library(bartMachine)
bartMachine::set_bart_machine_num_cores(16)
setwd("/home/rstudio")

res <- read.csv("thesis-scripts/data/GBM_ALL.csv")
res <- res[c("totalTime", "cores", "GBMemory", "trainingExamples", "numPredictors", "cells", "treeComplexity", "learningRate")]

gbm.testingInd <- sample(nrow(res), nrow(res) * 0.2)
gbm.testing <- res[gbm.testingInd,]
gbm.training <- res[-gbm.testingInd,]
gbm.training.predictors <- gbm.training[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells', "treeComplexity", "learningRate")]
gbm.training.predictors <- data.frame(gbm.training.predictors)
gbm.training.response <- log(gbm.training[[c("totalTime")]]) ## take the log for prediction
gbm.rf <- bartMachine(gbm.training.predictors, gbm.training.response, serialize = T)


## do prediction
gbm.testing.predictors <- gbm.testing[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells', 
"treeComplexity", "learningRate")]
gbm.testing.predictors <- data.frame(gbm.testing.predictors)
gbm.prediction <- predict(gbm.rf, gbm.testing.predictors)

## get statistics
gbm.mdCor <- cor(gbm.prediction, log(gbm.testing[['totalTime']]))
gbm.mdDelta <- gbm.prediction - log(gbm.testing$totalTime)
gbm.mdDelta.mean <- mean(gbm.mdDelta)
gbm.mdDelta.sd <- sd(gbm.mdDelta)
gbm.mdDelta.RSS <- sum((gbm.mdDelta)^2)
gbm.r2 <- gbm.mdCor^2
gbm.mse <- gbm.mdDelta.RSS / length(gbm.prediction)


## Plot
plot(gbm.prediction ~ log(gbm.testing[['totalTime']]), xlab="Observed", ylab="Predicted", main="Observed-Predicted Execution Time (GBM-BRT)")
abline(0, 1)

print(paste("Runtime Model Mean Squared Error: ", gbm.mdDelta.RSS/length(gbm.prediction)))
print(paste("Runtime Model Percent Variance Explained: ", gbm.r2, "%"))

gbm.post <- bart_machine_get_posterior(gbm.rf, gbm.testing.predictors)
gbm.post <- data.frame(gbm.post$y_hat_posterior_samples)
gbm.post$sd <- apply(gbm.post, 1, sd)

gbm.post.sdMean <- mean(gbm.post$sd)
print(paste("Runtime Model Posterior Mean Standard Deviation: ", gbm.post.sdMean))


res <- read.csv("thesis-scripts/data/GBM_ALL.csv")

gbm.testingInd.acc <- sample(nrow(res), nrow(res) * 0.2)
gbm.testing.acc <- res[gbm.testingInd.acc,]
gbm.training.acc <- res[-gbm.testingInd.acc,]

gbm.training.predictors.acc <- gbm.training.acc[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells',  "learningRate", "treeComplexity")]
gbm.training.predictors.acc <- data.frame(gbm.training.predictors.acc)
gbm.training.response.acc <- gbm.training.acc[[c("testingAUC")]] 

gbm.acc.rf <- bartMachine(gbm.training.predictors.acc, gbm.training.response.acc, serialize=T)

## do prediction
gbm.testing.predictors.acc <- gbm.testing.acc[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells',  "learningRate", "treeComplexity")]
gbm.testing.predictors.acc <- data.frame(gbm.testing.predictors.acc)
gbm.prediction.acc <- predict(gbm.acc.rf, gbm.testing.predictors.acc)

## get statistics
## get statistics
gbm.mdCor.acc <- cor(gbm.prediction.acc, gbm.testing.acc[['testingAUC']])
gbm.mdDelta.acc <- gbm.prediction.acc - gbm.testing.acc[[c("testingAUC")]] 
gbm.mdDelta.mean.acc <- mean(gbm.mdDelta.acc)
gbm.mdDelta.sd.acc <- sd(gbm.mdDelta.acc)
gbm.mdDelta.RSS.acc <- sum((gbm.mdDelta.acc)^2)
gbm.r2.acc <- gbm.mdCor.acc^2
gbm.mse.acc <- gbm.mdDelta.RSS.acc / length(gbm.prediction.acc)

## Plot
plot(gbm.prediction.acc ~ gbm.testing.acc[['testingAUC']], xlab="Observed AUC", 
ylab="Predicted AUC", main="Observed-Predicted AUC (GBM-BRT)")
abline(0, 1)

print(paste("Accuracy Model Mean Squared Error: ", gbm.mse.acc))
print(paste("Accuracy Model Percent Variance Explained: ", gbm.r2.acc, "%"))

gbm.post.acc <- bart_machine_get_posterior(gbm.acc.rf, gbm.testing.predictors.acc)
gbm.post.acc <- data.frame(gbm.post.acc$y_hat_posterior_samples)
gbm.post.acc$sd <- apply(gbm.post.acc, 1, sd)

gbm.post.sdMean.acc <- mean(gbm.post.acc$sd)
print(paste("Accuracy Model Posterior Mean Standard Deviation: ", gbm.post.sdMean.acc))

timingImp <- data.frame(investigate_var_importance(gbm.rf))
timingImp$predictor <- rownames(timingImp)
ggplot(timingImp) + geom_bar(aes(y = avg_var_props, x=predictor), stat="identity") +
ggtitle("Variable Importance in GBM Runtime Model")

accImp <- data.frame(investigate_var_importance(gbm.acc.rf))
accImp$predictor <- rownames(accImp)
ggplot(accImp) + geom_bar(aes(y = avg_var_props, x=predictor), stat="identity") +
ggtitle("Variable Importance in GBM Accuracy Model")


res <- read.csv("thesis-scripts/data/gam_full.csv")
res <- res[c("totalTime", "fittingTime", "cores", "GBMemory", "trainingExamples", "numPredictors", "cells")]

gam.testingInd <- sample(nrow(res), nrow(res) * 0.2)
gam.testing <- res[gam.testingInd,]
gam.training <- res[-gam.testingInd,]
gam.training.predictors <- gam.training[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
gam.training.predictors <- data.frame(gam.training.predictors)
gam.training.response <- log(gam.training[[c("totalTime")]]) ## take the log for prediction
gam.rf <- bartMachine(gam.training.predictors, gam.training.response, serialize=T)


## do prediction
gam.testing.predictors <- gam.testing[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
gam.testing.predictors <- data.frame(gam.testing.predictors)
gam.prediction <- predict(gam.rf, gam.testing.predictors)

## get statistics
gam.mdCor <- cor(gam.prediction, log(gam.testing[['totalTime']]))
gam.mdDelta <- gam.prediction - log(gam.testing$totalTime)
gam.mdDelta.mean <- mean(gam.mdDelta)
gam.mdDelta.sd <- sd(gam.mdDelta)
gam.mdDelta.RSS <- sum((gam.mdDelta)^2)
gam.r2 <- gam.mdCor ^ 2
gam.mse <- gam.mdDelta.RSS / length(gam.prediction)

## Plot
plot(gam.prediction ~ log(gam.testing[['totalTime']]), xlab="Observed", 
ylab="Predicted", main="Observed-Predicted Execution Time (GAM)")
abline(0, 1)

print(paste("Runtime Model Mean Squared Error: ",gam.mse))
print(paste("Runtime Model Percent Variance Explained: ", gam.r2, "%"))

gam.post <- bart_machine_get_posterior(gam.rf, gam.testing.predictors)
gam.post <- data.frame(gam.post$y_hat_posterior_samples)
gam.post$sd <- apply(gam.post, 1, sd)

gam.post.sdMean <- mean(gam.post$sd)
print(paste("Runtime Model Posterior Mean Standard Deviation: ", gam.post.sdMean))

res <- read.csv("thesis-scripts/data/gam_full.csv")

gam.testingInd.acc <- sample(nrow(res), nrow(res) * 0.2)
gam.testing.acc <- res[gam.testingInd.acc,]
gam.training.acc <- res[-gam.testingInd.acc,]

gam.training.predictors.acc <- gam.training.acc[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
gam.training.predictors.acc <- data.frame(gam.training.predictors.acc)
gam.training.response.acc <- gam.training.acc[[c("testingAUC")]] 

gam.acc.rf <- bartMachine(gam.training.predictors.acc, gam.training.response.acc, serialize=T)

## do prediction
gam.testing.predictors.acc <- gam.testing.acc[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
gam.testing.predictors.acc <- data.frame(gam.testing.predictors.acc)
gam.prediction.acc <- predict(gam.acc.rf, gam.testing.predictors.acc)

## get statistics
gam.mdCor.acc <- cor(gam.prediction.acc, gam.testing.acc[['testingAUC']])
gam.mdDelta.acc <- gam.prediction.acc - gam.testing.acc$testingAUC
gam.mdDelta.mean.acc <- mean(gam.mdDelta.acc)
gam.mdDelta.sd.acc <- sd(gam.mdDelta.acc)
gam.mdDelta.RSS.acc <- sum((gam.mdDelta.acc)^2)
gam.acc.mse <- gam.mdDelta.RSS.acc / length(gam.prediction.acc)
gam.acc.r2 <- gam.mdCor.acc ^ 2

## Plot
plot(gam.prediction.acc ~ gam.testing.acc[['testingAUC']], 
xlab="Observed AUC", ylab="Predicted AUC", main="Observed-Predicted AUC (GAM)")
abline(0, 1)

print(paste("Accuracy Model Mean Squared Error: ", gam.acc.mse))
print(paste("Accuracy Model Percent Variance Explained: ", gam.acc.r2, "%"))

gam.post.acc <- bart_machine_get_posterior(gam.acc.rf, gam.testing.predictors.acc)
gam.post.acc <- data.frame(gam.post.acc$y_hat_posterior_samples)
gam.post.acc$sd <- apply(gam.post.acc, 1, sd)

gam.post.sdMean.acc <- mean(gam.post.acc$sd)
print(paste("Accuracy Model Posterior Mean Standard Deviation: ", gam.post.sdMean.acc))

# timingImp.gam <- data.frame(importance(gam.rf))
# timingImp.gam$predictor <- rownames(timingImp.gam)
# ggplot(timingImp.gam) + geom_bar(aes(y = avg_var_props, x=predictor), stat="identity") +
# ggtitle("Variable Importance in GAM Runtime Model")
# 
# accImp.gam <- data.frame(importance(gam.acc.rf))
# accImp.gam$predictor <- rownames(accImp.gam)
# ggplot(accImp.gam) + geom_bar(aes(y = avg_var_props, x=predictor), stat="identity") +
# ggtitle("Variable Importance in GAM Accuracy Model")


res <- read.csv("thesis-scripts/data/mars_full.csv")
res <- res[c("totalTime", "fittingTime", "cores", "GBMemory", "trainingExamples", "numPredictors", "cells")]

mars.testingInd <- sample(nrow(res), nrow(res) * 0.2)
mars.testing <- res[mars.testingInd,]
mars.training <- res[-mars.testingInd,]
mars.training.predictors <- mars.training[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
mars.training.predictors <- data.frame(mars.training.predictors)
mars.training.response <- log(mars.training[[c("totalTime")]]) ## take the log for prediction
mars.rf <- bartMachine(mars.training.predictors, mars.training.response, serialize=T)


## do prediction
mars.testing.predictors <- mars.testing[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
mars.testing.predictors <- data.frame(mars.testing.predictors)
mars.prediction <- predict(mars.rf, mars.testing.predictors)

## get statistics
mars.mdCor <- cor(mars.prediction, log(mars.testing[['totalTime']]))
mars.mdDelta <- mars.prediction - log(mars.testing$totalTime)
mars.mdDelta.mean <- mean(mars.mdDelta)
mars.mdDelta.sd <- sd(mars.mdDelta)
mars.mdDelta.RSS <- sum((mars.mdDelta)^2)
mars.r2 <- mars.mdCor^2
mars.mse <- mars.mdDelta.RSS / length(mars.prediction)

## Plot
plot(mars.prediction ~ log(mars.testing[['totalTime']]), 
xlab="Observed", ylab="Predicted", main="Observed-Predicted Execution Time (MARS)")
abline(0, 1)

print(paste("Runtime Model Mean Squared Error: ", mars.mse))
print(paste("Runtime Model Percent Variance Explained: ", mars.r2, "%"))


mars.post <- bart_machine_get_posterior(mars.rf, mars.testing.predictors)
mars.post <- data.frame(mars.post$y_hat_posterior_samples)
mars.post$sd <- apply(mars.post, 1, sd)

mars.post.sdMean <- mean(mars.post$sd)
print(paste("Runtime Model Posterior Mean Standard Deviation: ", mars.post.sdMean))

res <- read.csv("thesis-scripts/data/mars_full.csv")

mars.testingInd.acc <- sample(nrow(res), nrow(res) * 0.2)
mars.testing.acc <- res[mars.testingInd.acc,]
mars.training.acc <- res[-mars.testingInd.acc,]

mars.training.predictors.acc <- mars.training.acc[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
mars.training.predictors.acc <- data.frame(mars.training.predictors.acc)
mars.training.response.acc <- mars.training.acc[[c("testingAUC")]] 

mars.acc.rf <- bartMachine(mars.training.predictors.acc, mars.training.response.acc, serialize = TRUE)

## do prediction
mars.testing.predictors.acc <- mars.testing.acc[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
mars.testing.predictors.acc <- data.frame(mars.testing.predictors.acc)
mars.prediction.acc <- predict(mars.acc.rf, mars.testing.predictors.acc)

## get statistics
mars.mdCor.acc <- cor(mars.prediction.acc, mars.testing.acc[['testingAUC']])
mars.mdDelta.acc <- mars.prediction.acc - mars.testing.acc$testingAUC
mars.mdDelta.mean.acc <- mean(mars.mdDelta.acc)
mars.mdDelta.sd.acc <- sd(mars.mdDelta.acc)
mars.mdDelta.RSS.acc <- sum((mars.mdDelta.acc)^2)
mars.r2.acc <- mars.mdCor.acc^2
mars.mse.acc <- mars.mdDelta.RSS.acc / length(mars.prediction.acc)


## Plot
plot(mars.prediction.acc ~ mars.testing.acc[['testingAUC']], 
xlab="Observed AUC", ylab="Predicted AUC", main="Observed-Predicted AUC (MARS)")
abline(0, 1)

print(paste("Accuracy Model Mean Squared Error: ", mars.mse.acc))
print(paste("Accuracy Model Percent Variance Explained: ", mars.r2.acc, "%"))

mars.post.acc <- bart_machine_get_posterior(mars.acc.rf, mars.testing.predictors.acc)
mars.post.acc <- data.frame(mars.post.acc$y_hat_posterior_samples)
mars.post.acc$sd <- apply(mars.post.acc, 1, sd)

mars.post.acc.sdMean <- mean(mars.post.acc$sd)
print(paste("Accuracy Model Posterior Mean Standard Deviation: ", mars.post.acc.sdMean))

# 
# additionalName = vector()
# mse.acc.imp = vector()
# r2.acc.imp = vector()
# 
# predNames = vector()
# for (i in 1:length(names(mars.training.predictors.acc))){
# predName = names(mars.training.predictors.acc)[i]
# predSet <- mars.training.predictors.acc
# predSet[[predName]] <- NULL
# 
# testSet <- mars.testing.predictors
# testSet[[predName]] <- NULL
# 
# model <- bartMachine(predSet, mars.training.response.acc)
# 
# p <- predict(model, testSet)
# 
# pDelta <- p - mars.testing.acc$testingAUC
# 
# 
# RSS.acc <- sum((mars.mdDelta.acc)^2)
# 
# r2 <- cor(p, mars.testing.acc$testingAUC)^2
# 
# mse <- sum(RSS.acc) / length(p)
# 
# mse.acc.imp[i] <- mse 
# r2.acc.imp[i] <- r2 
# additionalName[i] <- names(mars.training.predictors.acc)[i]
# }
# 
# 
# 
# imp <- data.frame(additionalName, mse = mse.acc.imp, r2 = r2.acc.imp)
# imp$mse = imp$mse
# imp$r2 = imp$r2
# 
# ggplot(imp) + geom_bar(aes(x = additionalName, y = mse), stat='identity') + geom_abline(slope = 0, intercept=mars.mse.acc)

# timingImp.mars <- data.frame(investigate_var_importance(mars.rf))
# timingImp.mars$predictor <- rownames(timingImp.mars)
# ggplot(timingImp.mars) + geom_bar(aes(y = avg_var_props, x=predictor), stat="identity") +
# ggtitle("Variable Importance in MARS Runtime Model")
# 
# accImp.mars <- data.frame(investigate_var_importance(mars.acc.rf))
# accImp.mars$predictor <- rownames(accImp.mars)
# ggplot(accImp.mars) + geom_bar(aes(y = avg_var_props, x=predictor), stat="identity") +
# ggtitle("Variable Importance in MARS Accuracy Model")
# 

res <- read.csv("thesis-scripts/data/rf_full.csv")
res <- res[c("totalTime", "fittingTime", "cores", "GBMemory", "trainingExamples", "numPredictors", "cells", "method")]
# dummy variables for method factor
res$seq<- 0
res$seq[res$method == 'SERIAL'] <- 1
res$par <- 0
res$par[res$method == "PARALLEL"] <- 1
rf.testingInd <- sample(nrow(res), nrow(res) * 0.2)
rf.testing <- res[rf.testingInd,]
rf.training <- res[-rf.testingInd,]
rf.training.predictors <- rf.training[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells', "par", "seq")]
rf.training.predictors <- data.frame(rf.training.predictors)
rf.training.response <- log(rf.training[[c("totalTime")]]) ## take the log for prediction
rf.rf <- bartMachine(rf.training.predictors, rf.training.response, serialize=T)


## do prediction
rf.testing.predictors <- rf.testing[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells', "par", "seq")]
rf.testing.predictors <- data.frame(rf.testing.predictors)
rf.prediction <- predict(rf.rf, rf.testing.predictors)

## get statistics
rf.mdCor <- cor(rf.prediction, log(rf.testing[['totalTime']]))
rf.mdDelta <- rf.prediction - log(rf.testing$totalTime)
rf.mdDelta.mean <- mean(rf.mdDelta)
rf.mdDelta.sd <- sd(rf.mdDelta)
rf.mdDelta.RSS <- sum((rf.mdDelta)^2)
rf.mse <- rf.mdDelta.RSS / length(rf.prediction)
rf.r2 <- rf.mdCor ^ 2

## Plot
plot(rf.prediction ~ log(rf.testing[['totalTime']]), 
xlab="Observed", ylab="Predicted", main="Observed-Predicted Execution Time (RF)")
abline(0, 1)

print(paste("Runtime Model Mean Squared Error: ", rf.mse))
print(paste("Runtime Model Percent Variance Explained: ", rf.r2, "%"))

rf.post <- bart_machine_get_posterior(rf.rf, rf.testing.predictors)
rf.post <- data.frame(rf.post$y_hat_posterior_samples)
rf.post$sd <- apply(rf.post, 1, sd)
rf.post.sdMean <- mean(rf.post$sd)
print(paste("Runtime Model Posterior Mean Standard Deviation: ", rf.post.sdMean))


res <- read.csv("thesis-scripts/data/rf_full.csv")

rf.testingInd.acc <- sample(nrow(res), nrow(res) * 0.2)
rf.testing.acc <- res[rf.testingInd.acc,]
rf.training.acc <- res[-rf.testingInd.acc,]

rf.training.predictors.acc <- rf.training.acc[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
rf.training.predictors.acc <- data.frame(rf.training.predictors.acc)
rf.training.response.acc <- rf.training.acc[[c("testingAUC")]] 

rf.acc.rf <- bartMachine(mars.training.predictors.acc, mars.training.response.acc, serialize=T)

## do prediction
rf.testing.predictors.acc <- rf.testing.acc[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
rf.testing.predictors.acc <- data.frame(rf.testing.predictors.acc)
rf.prediction.acc <- predict(rf.acc.rf, rf.testing.predictors.acc)

## get statistics
rf.mdCor.acc <- cor(rf.prediction.acc, rf.testing.acc[['testingAUC']])
rf.mdDelta.acc <- rf.prediction.acc - rf.testing.acc$testingAUC
rf.mdDelta.mean.acc <- mean(rf.mdDelta.acc)
rf.mdDelta.sd.acc <- sd(rf.mdDelta.acc)
rf.mdDelta.RSS.acc <- sum((rf.mdDelta.acc)^2)
rf.r2.acc <- rf.mdCor.acc ^ 2
rf.mse.acc <- rf.mdDelta.RSS.acc / length(rf.prediction.acc)


## Plot
plot(rf.prediction.acc ~ rf.testing.acc[['testingAUC']], 
xlab="Observed AUC", ylab="Predicted AUC", main="Observed-Predicted AUC (RF)")
abline(0, 1)

print(paste("Accuracy Model Mean Squared Error: ", rf.mse.acc))
print(paste("Accuracy Model Percent Variance Explained: ", rf.r2.acc, "%"))

rf.post.acc <- bart_machine_get_posterior(rf.acc.rf, rf.testing.predictors.acc)
rf.post.acc <- data.frame(rf.post.acc$y_hat_posterior_samples)
rf.post.acc$sd <- apply(rf.post.acc, 1, sd)

rf.post.acc.sdMean <- mean(rf.post.acc$sd)
print(paste("Accuracy Model Posterior Mean Standard Deviation: ", rf.post.acc.sdMean))

# timingImp.rf <- data.frame(importance(rf.rf))
# timingImp.rf$predictor <- rownames(timingImp.rf)
# ggplot(timingImp.rf) + geom_bar(aes(y = avg_var_props, x=predictor), stat="identity") +
# ggtitle("Variable Importance in Random Forest Runtime Model")
# 
# accImp.rf <- data.frame(importance(rf.acc.rf))
# accImp.rf$predictor <- rownames(accImp.rf)
# ggplot(accImp.rf) + geom_bar(aes(yw = avg_var_props, x=predictor), stat="identity") +
# ggtitle("Variable Importance in Random Forest Accuracy Model")



learningRateOpts <- seq(0.001, 0.11, by=0.05)
treeComplexityOpts <- seq(1, 5)
nTexOpts <- seq(0, 100000, by=10000)
cellOpts <- seq(10000, 100000, by=100000)
nPOpts <- seq(1, 5)

prices <- read.csv("data/costs.csv")

n = length(learningRateOpts) * 
  length(treeComplexityOpts) *
  length(nTexOpts) *
  length(cellOpts) *
  length(nPOpts) *
  nrow(prices)

hypercube <- expand.grid(learningRate = learningRateOpts, 
                         treeComplexity = treeComplexityOpts, 
                         trainingExamples = nTexOpts, 
                         cells = cellOpts, 
                         numPredictors = nPOpts, 
                         config = unique(prices$ConfigurationNumber),
                         seconds = 0,
                         cost = 0,
                         accuracy = 0)

timeAndCost <- merge(hypercube, prices, b.x = "config", b.y = "ConfigurationNumber")

timeAndCost <- data.frame(matrix(unlist(timeAndCost), ncol=10, nrow=length(timeAndCost), byrow=T))

f <- function(i){
  scenario <- timeAndCost[i, ]
  logTime <- predict(gbm.rf,  scenario)
  acc <- predict(gbm.acc.rf, scenario)
  timePred <- exp(logTime)
  thisComp.price <- thisComp$TotalRate## this is rate per hour
  thisComp.pricePerSecond <- thisComp.price / 3600 ## this is rate per second
  scenarioCost <- timePred * thisComp.pricePerSecond
  scenario$cost <- scenarioCost
  scenario$accuracy <- acc
  scenario$seconds <- timePred
  return(scenario)
}

results <- mclapply(1:nrow(timeAndCost), f)
r <-  data.frame(matrix(unlist(results), ncol=10, nrow=length(results), byrow=T))
names(r) <- names(results[[1]])
write.csv(r, "data/timeCost_gbm_all.csv")









