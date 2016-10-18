# install.packages('rJava')
# install.packages('bartMachine')
# install.packages('matrixStats')
# install.packages('ggplot2')
# install.packages('reshape2')
# install.packages('itertools')
library(ggplot2)
library(matrixStats)
library(reshape2)
options(java.parameters = "-Xmx15g") ## change memory allotment to RJava
library(bartMachine)
bartMachine::set_bart_machine_num_cores(8)
setwd("/home/rstudio")
library(data.table)
library(itertools)


############################################################################################################
####GBM-BRT####
############################################################################################################
# 
# #### Fit the timing model
# res <- read.csv("thesis-scripts/data/GBM_ALL.csv")
# res <- res[c("totalTime", "cores", "GBMemory", "trainingExamples", "numPredictors", "cells", "treeComplexity", "learningRate")]
# 
# gbm.testingInd <- sample(nrow(res), nrow(res) * 0.2)
# gbm.testing <- res[gbm.testingInd,]
# gbm.training <- res[-gbm.testingInd,]
# gbm.training.predictors <- gbm.training[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells', "treeComplexity", "learningRate")]
# gbm.training.predictors <- data.frame(gbm.training.predictors)
# gbm.training.response <- log(gbm.training[[c("totalTime")]]) ## take the log for prediction
# gbm.rf <- bartMachine(gbm.training.predictors, gbm.training.response, serialize = T)
# 
# 
# ## do prediction
# gbm.testing.predictors <- gbm.testing[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells', 
#                                          "treeComplexity", "learningRate")]
# gbm.testing.predictors <- data.frame(gbm.testing.predictors)
# gbm.prediction <- predict(gbm.rf, gbm.testing.predictors)
# 
# ## get statistics
# gbm.mdCor <- cor(gbm.prediction, log(gbm.testing[['totalTime']]))
# gbm.mdDelta <- gbm.prediction - log(gbm.testing$totalTime)
# gbm.mdDelta.mean <- mean(gbm.mdDelta)
# gbm.mdDelta.sd <- sd(gbm.mdDelta)
# gbm.mdDelta.RSS <- sum((gbm.mdDelta)^2)
# gbm.r2 <- gbm.mdCor^2
# gbm.mse <- gbm.mdDelta.RSS / length(gbm.prediction)
# 
# 
# ## Plot
# plot(gbm.prediction ~ log(gbm.testing[['totalTime']]), xlab="Observed", ylab="Predicted", main="Observed-Predicted Execution Time (GBM-BRT)")
# abline(0, 1)
# 
# print(paste("Runtime Model Mean Squared Error: ", gbm.mdDelta.RSS/length(gbm.prediction)))
# print(paste("Runtime Model Percent Variance Explained: ", gbm.r2, "%"))
# 
# gbm.post <- bart_machine_get_posterior(gbm.rf, gbm.testing.predictors)
# gbm.post <- data.frame(gbm.post$y_hat_posterior_samples)
# gbm.post$sd <- apply(gbm.post, 1, sd)
# 
# gbm.post.sdMean <- mean(gbm.post$sd)
# print(paste("Runtime Model Posterior Mean Standard Deviation: ", gbm.post.sdMean))
# 
# ### Fit the accuracy model
# res <- read.csv("thesis-scripts/data/GBM_ALL.csv")
# 
# gbm.testingInd.acc <- sample(nrow(res), nrow(res) * 0.2)
# gbm.testing.acc <- res[gbm.testingInd.acc,]
# gbm.training.acc <- res[-gbm.testingInd.acc,]
# 
# gbm.training.predictors.acc <- gbm.training.acc[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells',  "learningRate", "treeComplexity")]
# gbm.training.predictors.acc <- data.frame(gbm.training.predictors.acc)
# gbm.training.response.acc <- gbm.training.acc[[c("testingAUC")]] 
# 
# gbm.acc.rf <- bartMachine(gbm.training.predictors.acc, gbm.training.response.acc, serialize=T)
# 
# ## do prediction
# gbm.testing.predictors.acc <- gbm.testing.acc[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells',  "learningRate", "treeComplexity")]
# gbm.testing.predictors.acc <- data.frame(gbm.testing.predictors.acc)
# gbm.prediction.acc <- predict(gbm.acc.rf, gbm.testing.predictors.acc)
# 
# ## get statistics
# ## get statistics
# gbm.mdCor.acc <- cor(gbm.prediction.acc, gbm.testing.acc[['testingAUC']])
# gbm.mdDelta.acc <- gbm.prediction.acc - gbm.testing.acc[[c("testingAUC")]] 
# gbm.mdDelta.mean.acc <- mean(gbm.mdDelta.acc)
# gbm.mdDelta.sd.acc <- sd(gbm.mdDelta.acc)
# gbm.mdDelta.RSS.acc <- sum((gbm.mdDelta.acc)^2)
# gbm.r2.acc <- gbm.mdCor.acc^2
# gbm.mse.acc <- gbm.mdDelta.RSS.acc / length(gbm.prediction.acc)
# 
# ## Plot
# plot(gbm.prediction.acc ~ gbm.testing.acc[['testingAUC']], xlab="Observed AUC", 
#      ylab="Predicted AUC", main="Observed-Predicted AUC (GBM-BRT)")
# abline(0, 1)
# 
# print(paste("Accuracy Model Mean Squared Error: ", gbm.mse.acc))
# print(paste("Accuracy Model Percent Variance Explained: ", gbm.r2.acc, "%"))
# 
# gbm.post.acc <- bart_machine_get_posterior(gbm.acc.rf, gbm.testing.predictors.acc)
# gbm.post.acc <- data.frame(gbm.post.acc$y_hat_posterior_samples)
# gbm.post.acc$sd <- apply(gbm.post.acc, 1, sd)
# 
# gbm.post.sdMean.acc <- mean(gbm.post.acc$sd)
# print(paste("Accuracy Model Posterior Mean Standard Deviation: ", gbm.post.sdMean.acc))
# 
# ### Cross validate model drivers
# additionalName.gbm = vector()
# gbm.imp = vector()
# 
# for (i in 1:length(names(gbm.training.predictors))){
#   predName = names(gbm.training.predictors)[i]
#   predSet <- gbm.training.predictors
#   predSet[[predName]] <- NULL
#   
#   testSet <- gbm.testing.predictors
#   testSet[[predName]] <- NULL
#   
#   print(names(testSet))
#   print(names(predSet))
#   
#   ## timing
#   model <- bartMachine(predSet, gbm.training.response, run_in_sample = F, verbose = FALSE)
#   p <- predict(model, testSet)
#   pDelta <- p - log(gbm.testing$totalTime)
#   RSS <- sum((pDelta)^2)
#   r2 <- cor(p, log(gbm.testing$totalTime))^2
#   mse <- sum(RSS) / length(p)
#   gbm.imp[i] <- r2
#   
#   additionalName.gbm[i] <- predName
# }
# 
# gbm.imp.acc <- vector()
# for (i in 1:length(names(gbm.training.predictors.acc))){
#   predName = names(gbm.training.predictors.acc)[i]
#   predSet <- gbm.training.predictors.acc
#   predSet[[predName]] <- NULL
#   
#   testSet <- gbm.testing.predictors.acc
#   testSet[[predName]] <- NULL
#   
#   print(names(testSet))
#   print(names(predSet))
#   
#   ## timing
#   model <- bartMachine(predSet, gbm.training.response.acc, run_in_sample = F, verbose = FALSE)
#   p <- predict(model, testSet)
#   pDelta <- p - gbm.testing.acc$testingAUC
#   RSS <- sum((pDelta)^2)
#   r2 <- cor(p, gbm.testing.acc$testingAUC)^2
#   mse <- RSS / length(p)
#   gbm.imp.acc[i] <- r2
#   
#   additionalName.gbm[i] <- predName
# }
# 
# gbm.importance <- data.frame(absentName = additionalName.gbm, r2.acc = gbm.imp.acc, r2.timing = gbm.imp)
# 
# 
# gbm.importance$acc.reduction <- gbm.importance$r2.acc - gbm.r2.acc
# gbm.importance$timing.reduction <- gbm.importance$r2.timing - gbm.r2
# 
# 
# gbm.importance.plot <- gbm.importance[c("timing.reduction", "acc.reduction", "absentName")]
# gbm.importance.plot <- melt(gbm.importance.plot, id.vars="absentName")
# 
# ggplot(gbm.importance.plot) + 
#   geom_bar(aes(x = absentName, y = value, group= variable, fill=variable), 
#            stat='identity', position = "dodge") +
#   ylab("Reduction in Explained Variance") +
#   ggtitle("GBM-BRT Model Drivers") +
#   theme(axis.text.x = element_text(angle = 90)) 



############################################################################################################
####GAM####
############################################################################################################

### Fit the timing model
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



### Fit the GAM accuracy Model
gam.post <- bart_machine_get_posterior(gam.rf, gam.testing.predictors)
gam.post <- data.frame(gam.post$y_hat_posterior_samples)
gam.post$sd <- apply(gam.post, 1, sd)

gam.post.sdMean <- mean(gam.post$sd)
print(paste("Runtime Model Posterior Mean Standard Deviation: ", gam.post.sdMean))

res <- read.csv("thesis-scripts/data/gam_full.csv")

gam.testingInd.acc <- sample(nrow(res), nrow(res) * 0.2)
gam.testing.acc <- res[gam.testingInd.acc,]
gam.training.acc <- res[-gam.testingInd.acc,]

gam.training.predictors.acc <- gam.training.acc[c( "numPredictors", "cores", "GBMemory", 
                                                   "trainingExamples", 'cells')]
gam.training.predictors.acc <- data.frame(gam.training.predictors.acc)
gam.training.response.acc <- gam.training.acc[[c("testingAUC")]] 

gam.acc.rf <- bartMachine(gam.training.predictors.acc, gam.training.response.acc, serialize=T)

## do prediction
gam.testing.predictors.acc <- gam.testing.acc[c( "numPredictors", "cores", "GBMemory", 
                                                 "trainingExamples", 'cells')]
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

# 
# ### Cross validate GAM model to evaluate model drivers
# additionalName.gam = vector()
# gam.imp = vector()
# 
# predNames = vector()
# for (i in 1:length(names(gam.training.predictors))){
#   predName = names(gam.training.predictors)[i]
#   predSet <- gam.training.predictors
#   predSet[[predName]] <- NULL
#   
#   testSet <- gam.testing.predictors
#   testSet[[predName]] <- NULL
#   
#   print(names(testSet))
#   print(names(predSet))
#   
#   ## timing
#   model <- bartMachine(predSet, gam.training.response, run_in_sample = F, verbose = FALSE)
#   p <- predict(model, testSet)
#   pDelta <- p - log(gam.testing$totalTime)
#   RSS <- sum((pDelta)^2)
#   r2 <- cor(p, log(gam.testing$totalTime))^2
#   mse <- sum(RSS) / length(p)
#   gam.imp[i] <- r2
#   
#   additionalName.gam[i] <- predName
# }
# 
# additionalName.gam = vector()
# gam.imp.acc = vector()
# predNames = vector()
# for (i in 1:length(names(gam.training.predictors.acc))){
#   predName = names(gam.training.predictors.acc)[i]
#   predSet <- gam.training.predictors.acc
#   predSet[[predName]] <- NULL
#   
#   testSet <- gam.testing.predictors.acc
#   testSet[[predName]] <- NULL
#   
#   print(names(testSet))
#   print(names(predSet))
#   
#   ## timing
#   model <- bartMachine(predSet, gam.training.response.acc, run_in_sample = F, verbose = FALSE)
#   p <- predict(model, testSet)
#   pDelta <- p - gam.testing.acc$testingAUC
#   RSS <- sum((pDelta)^2)
#   r2 <- cor(p, gam.testing.acc$testingAUC)^2
#   mse <- sum(RSS) / length(p)
#   gam.imp.acc[i] <- r2
#   
#   additionalName.gam[i] <- predName
# }
# 
# gam.importance <- data.frame(absentName = additionalName.gam, r2.acc = gam.imp.acc, r2.timing = gam.imp)
# 
# 
# gam.importance$acc.reduction <- gam.importance$r2.acc - gam.acc.r2
# gam.importance$timing.reduction <- gam.importance$r2.timing - gam.r2
# 
# 
# gam.importance.plot <- gam.importance[c("timing.reduction", "acc.reduction", "absentName")]
# gam.importance.plot <- melt(gam.importance.plot, id.vars="absentName")
# 
# ggplot(gam.importance.plot) + 
#   geom_bar(aes(x = absentName, y = value, group= variable, fill=variable), 
#            stat='identity', position = "dodge") +
#   ylab("Reduction in Explained Variance") +
#   ggtitle("GAM Model Drivers") + 
#   theme(axis.text.x = element_text(angle = 90)) 
# 
# 


############################################################################################################
####MARS####
############################################################################################################


## Fit the MARS timnig model

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




### Fit the MARS accuracy model
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




### Cross validate to determine model drivers for MARS
additionalName.mars = vector()
mars.imp = vector()
mars.imp.acc = vector()

predNames = vector()
for (i in 1:length(names(mars.training.predictors))){
  predName = names(mars.training.predictors)[i]
  predSet <- mars.training.predictors
  predSet[[predName]] <- NULL
  
  testSet <- mars.testing.predictors
  testSet[[predName]] <- NULL
  
  print(names(testSet))
  print(names(predSet))
  
  ## timing
  model <- bartMachine(predSet, mars.training.response, run_in_sample = F, verbose = FALSE)
  p <- predict(model, testSet)
  pDelta <- p - log(mars.testing$totalTime)
  RSS <- sum((pDelta)^2)
  r2 <- cor(p, log(mars.testing$totalTime))^2
  mse <- RSS / length(p)
  mars.imp[i] <- r2
  
  additionalName.mars[i] <- predName
}

for (i in 1:length(names(mars.training.predictors.acc))){
  predName = names(mars.training.predictors.acc)[i]
  predSet <- mars.training.predictors.acc
  predSet[[predName]] <- NULL
  
  testSet <- mars.testing.predictors.acc
  testSet[[predName]] <- NULL
  
  print(names(testSet))
  print(names(predSet))
  
  ## timing
  model <- bartMachine(predSet, mars.training.response.acc, run_in_sample = F, verbose = FALSE)
  p <- predict(model, testSet)
  pDelta <- p - mars.testing.acc$testingAUC
  RSS <- sum((pDelta)^2)
  r2 <- cor(p, mars.testing.acc$testingAUC)^2
  mse <- sum(RSS) / length(p)
  mars.imp.acc[i] <- r2
  
  additionalName.mars[i] <- predName
}


mars.importance <- data.frame(absentName = additionalName.mars, r2.acc = mars.imp.acc, r2.timing = mars.imp)


mars.importance$acc.reduction <- mars.importance$r2.acc - mars.r2.acc
mars.importance$timing.reduction <- mars.importance$r2.timing - mars.r2


mars.importance.plot <- mars.importance[c("timing.reduction", "acc.reduction", "absentName")]
mars.importance.plot <- melt(mars.importance.plot, id.vars="absentName")

ggplot(mars.importance.plot) + 
  geom_bar(aes(x = absentName, y = value, group= variable, fill=variable), 
           stat='identity', position = "dodge") +
  ylab("Reduction in Explained Variance") +
  ggtitle("MARS Model Drivers") +
  theme(axis.text.x = element_text(angle = 90)) 


############################################################################################################
####RF####
############################################################################################################



### Fit the timing model
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




### Fit the accuracy model
res <- read.csv("thesis-scripts/data/rf_full.csv")
res$seq<- 0
res$seq[res$method == 'SERIAL'] <- 1
res$par <- 0
res$par[res$method == "PARALLEL"] <- 1

rf.testingInd.acc <- sample(nrow(res), nrow(res) * 0.2)
rf.testing.acc <- res[rf.testingInd.acc,]
rf.training.acc <- res[-rf.testingInd.acc,]

rf.training.predictors.acc <- rf.training.acc[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]

rf.training.predictors.acc <- data.frame(rf.training.predictors.acc)
rf.training.response.acc <- rf.training.acc[[c("testingAUC")]] 

rf.acc.rf <- bartMachine(rf.training.predictors.acc, rf.training.response.acc, serialize=T)

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


### Cross validate to evaluate model drivers for RF
# 
# 
# additionalName.rf = vector()
# rf.imp = vector()
# 
# predNames = vector()
# for (i in 1:length(names(rf.training.predictors))){
#   predName = names(rf.training.predictors)[i]
#   predSet <- rf.training.predictors
#   predSet[[predName]] <- NULL
#   
#   testSet <- rf.testing.predictors
#   testSet[[predName]] <- NULL
#   
#   print(names(testSet))
#   print(names(predSet))
#   
#   ## timing
#   model <- bartMachine(predSet, rf.training.response, run_in_sample = F, verbose = FALSE)
#   p <- predict(model, testSet)
#   pDelta <- p - log(rf.testing$totalTime)
#   RSS <- sum((pDelta)^2)
#   r2 <- cor(p, log(rf.testing$totalTime))^2
#   mse <- sum(RSS) / length(p)
#   rf.imp[i] <- r2
#   
#   additionalName.rf[i] <- predName
# }
# 
# rf.imp.acc <- vector()
# for (i in 1:length(names(rf.training.predictors.acc))){
#   predName = names(rf.training.predictors.acc)[i]
#   predSet <- rf.training.predictors.acc
#   predSet[[predName]] <- NULL
#   
#   testSet <- rf.testing.predictors.acc
#   testSet[[predName]] <- NULL
#   
#   print(names(testSet))
#   print(names(predSet))
#   
#   ## timing
#   model <- bartMachine(predSet, rf.training.response.acc, run_in_sample = F, verbose = FALSE)
#   p <- predict(model, testSet)
#   pDelta <- p - rf.testing.acc$testingAUC
#   RSS <- sum((pDelta)^2)
#   r2 <- cor(p, rf.testing.acc$testingAUC)^2
#   mse <- sum(RSS) / length(p)
#   rf.imp.acc[i] <- r2
#   
#   plot(p, rf.testing.acc$testingAUC )
#   
#   additionalName.rf[i] <- predName
# }
# 
# 
# rf.imp.acc <-c(rf.imp.acc, NA, NA)
# 
# rf.importance <- data.frame(absentName = additionalName.rf, r2.acc = rf.imp.acc, r2.timing = rf.imp)
# 
# 
# rf.importance$acc.reduction <- rf.importance$r2.acc - rf.r2.acc
# rf.importance$timing.reduction <- rf.importance$r2.timing - rf.r2
# 
# 
# rf.importance.plot <- rf.importance[c("timing.reduction", "acc.reduction", "absentName")]
# rf.importance.plot <- melt(rf.importance.plot, id.vars="absentName")
# 
# ggplot(rf.importance.plot) + 
#   geom_bar(aes(x = absentName, y = value, group= variable, fill=variable), 
#            stat='identity', position = "dodge") +
#   ylab("Reduction in Explained Variance") +
#   ggtitle("RF Model Drivers") +
#   theme(axis.text.x = element_text(angle = 90)) 

############################################################################################################
####Hypercube Generation####
############################################################################################################

# 
# ## Regular sampling
# learningRateOpts <- seq(0.001, 0.11, by=0.1)
# treeComplexityOpts <- seq(1, 5)
# nTexOpts <- seq(0, 250000, by=5000)
# cellOpts <- seq(10000, 100000, by=100000)
# nPOpts <- seq(1, 5)
# 
# prices <- read.csv("thesis-scripts/data/costs.csv")
# 
# n = length(learningRateOpts) * 
#   length(treeComplexityOpts) *
#   length(nTexOpts) *
#   length(cellOpts) *
#   length(nPOpts) *
#   nrow(prices)
# 
# ## make the hypergrid
# hypercube <- expand.grid(learningRate = learningRateOpts, 
#                          treeComplexity = treeComplexityOpts, 
#                          trainingExamples = nTexOpts, 
#                          cells = cellOpts, 
#                          numPredictors = nPOpts, 
#                          config = unique(prices$ConfigurationNumber),
#                          seconds = 0,
#                          cost = 0,
#                          accuracy = 0)
# 
# 
# ## merge with costs
# timeAndCost <- merge(hypercube, prices, b.x = "config", b.y = "ConfigurationNumber")
# 
# f <- function(i){
#   scenario <- timeAndCost[i, ]
#   logTime <- predict(gbm.rf,  scenario)
#   acc <- predict(gbm.acc.rf, scenario)
#   timePred <- exp(logTime)
#   thisComp.price <- thisComp$TotalRate## this is rate per hour
#   thisComp.pricePerSecond <- thisComp.price / 3600 ## this is rate per second
#   scenarioCost <- timePred * thisComp.pricePerSecond
#   scenario$cost <- scenarioCost
#   scenario$accuracy <- acc
#   scenario$seconds <- timePred
#   return(scenario)
# }
# 
# 
# ## do the prediction, spread out over all cores
# results <- mclapply(1:nrow(timeAndCost), f)
# r <-  data.frame(matrix(unlist(results), ncol=10, nrow=length(results), byrow=T))
# names(r) <- names(results[[1]])
# write.csv(r, "data/timeCost_gbm_all.csv")



nTexOpts <- seq(0, 100000, by=10000)
cellOpts <- seq(10000, 100000, by=100000)
nPOpts <- seq(1, 5)

prices <- read.csv("thesis-scripts/data/costs.csv")

n = length(nTexOpts) *
  length(cellOpts) *
  length(nPOpts) *
  nrow(prices)

## make the hypergrid
hypercube <- expand.grid(trainingExamples = nTexOpts,
                         cells = cellOpts,
                         numPredictors = nPOpts,
                         config = unique(prices$ConfigurationNumber),
                         seconds = 0,
                         cost = 0,
                         accuracy = 0)


## merge with costs
timeAndCost <- merge(hypercube, prices, b.x = "config", b.y = "ConfigurationNumber")

predictors <- timeAndCost[c("numPredictors", "CPUs", "GBsMem", "trainingExamples", "cells")]
names(predictors) <- names(gam.testing.predictors)

library(doParallel)
registerDoParallel(8)


pl <- split(predictors, 1:10)

predictions <-
  foreach(d=1:length(pl),
          .combine=c, .packages=c("stats", "bartMachine")) %dopar% {
            predict(gam.rf, pl[[d]])
          }

predictions.acc <-
  foreach(d=1:length(pl),
          .combine=c, .packages=c("stats", "bartMachine")) %dopar% {
            predict(gam.acc.rf, pl[[d]])
          }

timeAndCost$seconds <- predictions
timeAndCost$accuracy <- predictions.acc
timeAndCost$cost <- timeAndCost$seconds * (timeAndCost$TotalRate/3600)
write.csv(timeAndCost, "data/timeCost_gam_all.csv")
# 
# # install.packages('rJava')
# install.packages('bartMachine')
# install.packages('matrixStats')
# install.packages('ggplot2')
# install.packages('reshape2')
# install.packages('itertools')
library(ggplot2)
library(matrixStats)
library(reshape2)
options(java.parameters = "-Xmx15g") ## change memory allotment to RJava
library(bartMachine)
bartMachine::set_bart_machine_num_cores(8)
setwd("/home/rstudio")
library(data.table)
library(itertools)


############################################################################################################
####GBM-BRT####
############################################################################################################
# 
# #### Fit the timing model
# res <- read.csv("thesis-scripts/data/GBM_ALL.csv")
# res <- res[c("totalTime", "cores", "GBMemory", "trainingExamples", "numPredictors", "cells", "treeComplexity", "learningRate")]
# 
# gbm.testingInd <- sample(nrow(res), nrow(res) * 0.2)
# gbm.testing <- res[gbm.testingInd,]
# gbm.training <- res[-gbm.testingInd,]
# gbm.training.predictors <- gbm.training[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells', "treeComplexity", "learningRate")]
# gbm.training.predictors <- data.frame(gbm.training.predictors)
# gbm.training.response <- log(gbm.training[[c("totalTime")]]) ## take the log for prediction
# gbm.rf <- bartMachine(gbm.training.predictors, gbm.training.response, serialize = T)
# 
# 
# ## do prediction
# gbm.testing.predictors <- gbm.testing[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells', 
#                                          "treeComplexity", "learningRate")]
# gbm.testing.predictors <- data.frame(gbm.testing.predictors)
# gbm.prediction <- predict(gbm.rf, gbm.testing.predictors)
# 
# ## get statistics
# gbm.mdCor <- cor(gbm.prediction, log(gbm.testing[['totalTime']]))
# gbm.mdDelta <- gbm.prediction - log(gbm.testing$totalTime)
# gbm.mdDelta.mean <- mean(gbm.mdDelta)
# gbm.mdDelta.sd <- sd(gbm.mdDelta)
# gbm.mdDelta.RSS <- sum((gbm.mdDelta)^2)
# gbm.r2 <- gbm.mdCor^2
# gbm.mse <- gbm.mdDelta.RSS / length(gbm.prediction)
# 
# 
# ## Plot
# plot(gbm.prediction ~ log(gbm.testing[['totalTime']]), xlab="Observed", ylab="Predicted", main="Observed-Predicted Execution Time (GBM-BRT)")
# abline(0, 1)
# 
# print(paste("Runtime Model Mean Squared Error: ", gbm.mdDelta.RSS/length(gbm.prediction)))
# print(paste("Runtime Model Percent Variance Explained: ", gbm.r2, "%"))
# 
# gbm.post <- bart_machine_get_posterior(gbm.rf, gbm.testing.predictors)
# gbm.post <- data.frame(gbm.post$y_hat_posterior_samples)
# gbm.post$sd <- apply(gbm.post, 1, sd)
# 
# gbm.post.sdMean <- mean(gbm.post$sd)
# print(paste("Runtime Model Posterior Mean Standard Deviation: ", gbm.post.sdMean))
# 
# ### Fit the accuracy model
# res <- read.csv("thesis-scripts/data/GBM_ALL.csv")
# 
# gbm.testingInd.acc <- sample(nrow(res), nrow(res) * 0.2)
# gbm.testing.acc <- res[gbm.testingInd.acc,]
# gbm.training.acc <- res[-gbm.testingInd.acc,]
# 
# gbm.training.predictors.acc <- gbm.training.acc[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells',  "learningRate", "treeComplexity")]
# gbm.training.predictors.acc <- data.frame(gbm.training.predictors.acc)
# gbm.training.response.acc <- gbm.training.acc[[c("testingAUC")]] 
# 
# gbm.acc.rf <- bartMachine(gbm.training.predictors.acc, gbm.training.response.acc, serialize=T)
# 
# ## do prediction
# gbm.testing.predictors.acc <- gbm.testing.acc[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells',  "learningRate", "treeComplexity")]
# gbm.testing.predictors.acc <- data.frame(gbm.testing.predictors.acc)
# gbm.prediction.acc <- predict(gbm.acc.rf, gbm.testing.predictors.acc)
# 
# ## get statistics
# ## get statistics
# gbm.mdCor.acc <- cor(gbm.prediction.acc, gbm.testing.acc[['testingAUC']])
# gbm.mdDelta.acc <- gbm.prediction.acc - gbm.testing.acc[[c("testingAUC")]] 
# gbm.mdDelta.mean.acc <- mean(gbm.mdDelta.acc)
# gbm.mdDelta.sd.acc <- sd(gbm.mdDelta.acc)
# gbm.mdDelta.RSS.acc <- sum((gbm.mdDelta.acc)^2)
# gbm.r2.acc <- gbm.mdCor.acc^2
# gbm.mse.acc <- gbm.mdDelta.RSS.acc / length(gbm.prediction.acc)
# 
# ## Plot
# plot(gbm.prediction.acc ~ gbm.testing.acc[['testingAUC']], xlab="Observed AUC", 
#      ylab="Predicted AUC", main="Observed-Predicted AUC (GBM-BRT)")
# abline(0, 1)
# 
# print(paste("Accuracy Model Mean Squared Error: ", gbm.mse.acc))
# print(paste("Accuracy Model Percent Variance Explained: ", gbm.r2.acc, "%"))
# 
# gbm.post.acc <- bart_machine_get_posterior(gbm.acc.rf, gbm.testing.predictors.acc)
# gbm.post.acc <- data.frame(gbm.post.acc$y_hat_posterior_samples)
# gbm.post.acc$sd <- apply(gbm.post.acc, 1, sd)
# 
# gbm.post.sdMean.acc <- mean(gbm.post.acc$sd)
# print(paste("Accuracy Model Posterior Mean Standard Deviation: ", gbm.post.sdMean.acc))
# 
# ### Cross validate model drivers
# additionalName.gbm = vector()
# gbm.imp = vector()
# 
# for (i in 1:length(names(gbm.training.predictors))){
#   predName = names(gbm.training.predictors)[i]
#   predSet <- gbm.training.predictors
#   predSet[[predName]] <- NULL
#   
#   testSet <- gbm.testing.predictors
#   testSet[[predName]] <- NULL
#   
#   print(names(testSet))
#   print(names(predSet))
#   
#   ## timing
#   model <- bartMachine(predSet, gbm.training.response, run_in_sample = F, verbose = FALSE)
#   p <- predict(model, testSet)
#   pDelta <- p - log(gbm.testing$totalTime)
#   RSS <- sum((pDelta)^2)
#   r2 <- cor(p, log(gbm.testing$totalTime))^2
#   mse <- sum(RSS) / length(p)
#   gbm.imp[i] <- r2
#   
#   additionalName.gbm[i] <- predName
# }
# 
# gbm.imp.acc <- vector()
# for (i in 1:length(names(gbm.training.predictors.acc))){
#   predName = names(gbm.training.predictors.acc)[i]
#   predSet <- gbm.training.predictors.acc
#   predSet[[predName]] <- NULL
#   
#   testSet <- gbm.testing.predictors.acc
#   testSet[[predName]] <- NULL
#   
#   print(names(testSet))
#   print(names(predSet))
#   
#   ## timing
#   model <- bartMachine(predSet, gbm.training.response.acc, run_in_sample = F, verbose = FALSE)
#   p <- predict(model, testSet)
#   pDelta <- p - gbm.testing.acc$testingAUC
#   RSS <- sum((pDelta)^2)
#   r2 <- cor(p, gbm.testing.acc$testingAUC)^2
#   mse <- RSS / length(p)
#   gbm.imp.acc[i] <- r2
#   
#   additionalName.gbm[i] <- predName
# }
# 
# gbm.importance <- data.frame(absentName = additionalName.gbm, r2.acc = gbm.imp.acc, r2.timing = gbm.imp)
# 
# 
# gbm.importance$acc.reduction <- gbm.importance$r2.acc - gbm.r2.acc
# gbm.importance$timing.reduction <- gbm.importance$r2.timing - gbm.r2
# 
# 
# gbm.importance.plot <- gbm.importance[c("timing.reduction", "acc.reduction", "absentName")]
# gbm.importance.plot <- melt(gbm.importance.plot, id.vars="absentName")
# 
# ggplot(gbm.importance.plot) + 
#   geom_bar(aes(x = absentName, y = value, group= variable, fill=variable), 
#            stat='identity', position = "dodge") +
#   ylab("Reduction in Explained Variance") +
#   ggtitle("GBM-BRT Model Drivers") +
#   theme(axis.text.x = element_text(angle = 90)) 



############################################################################################################
####GAM####
############################################################################################################

### Fit the timing model
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



### Fit the GAM accuracy Model
gam.post <- bart_machine_get_posterior(gam.rf, gam.testing.predictors)
gam.post <- data.frame(gam.post$y_hat_posterior_samples)
gam.post$sd <- apply(gam.post, 1, sd)

gam.post.sdMean <- mean(gam.post$sd)
print(paste("Runtime Model Posterior Mean Standard Deviation: ", gam.post.sdMean))

res <- read.csv("thesis-scripts/data/gam_full.csv")

gam.testingInd.acc <- sample(nrow(res), nrow(res) * 0.2)
gam.testing.acc <- res[gam.testingInd.acc,]
gam.training.acc <- res[-gam.testingInd.acc,]

gam.training.predictors.acc <- gam.training.acc[c( "numPredictors", "cores", "GBMemory", 
                                                   "trainingExamples", 'cells')]
gam.training.predictors.acc <- data.frame(gam.training.predictors.acc)
gam.training.response.acc <- gam.training.acc[[c("testingAUC")]] 

gam.acc.rf <- bartMachine(gam.training.predictors.acc, gam.training.response.acc, serialize=T)

## do prediction
gam.testing.predictors.acc <- gam.testing.acc[c( "numPredictors", "cores", "GBMemory", 
                                                 "trainingExamples", 'cells')]
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

# 
# ### Cross validate GAM model to evaluate model drivers
# additionalName.gam = vector()
# gam.imp = vector()
# 
# predNames = vector()
# for (i in 1:length(names(gam.training.predictors))){
#   predName = names(gam.training.predictors)[i]
#   predSet <- gam.training.predictors
#   predSet[[predName]] <- NULL
#   
#   testSet <- gam.testing.predictors
#   testSet[[predName]] <- NULL
#   
#   print(names(testSet))
#   print(names(predSet))
#   
#   ## timing
#   model <- bartMachine(predSet, gam.training.response, run_in_sample = F, verbose = FALSE)
#   p <- predict(model, testSet)
#   pDelta <- p - log(gam.testing$totalTime)
#   RSS <- sum((pDelta)^2)
#   r2 <- cor(p, log(gam.testing$totalTime))^2
#   mse <- sum(RSS) / length(p)
#   gam.imp[i] <- r2
#   
#   additionalName.gam[i] <- predName
# }
# 
# additionalName.gam = vector()
# gam.imp.acc = vector()
# predNames = vector()
# for (i in 1:length(names(gam.training.predictors.acc))){
#   predName = names(gam.training.predictors.acc)[i]
#   predSet <- gam.training.predictors.acc
#   predSet[[predName]] <- NULL
#   
#   testSet <- gam.testing.predictors.acc
#   testSet[[predName]] <- NULL
#   
#   print(names(testSet))
#   print(names(predSet))
#   
#   ## timing
#   model <- bartMachine(predSet, gam.training.response.acc, run_in_sample = F, verbose = FALSE)
#   p <- predict(model, testSet)
#   pDelta <- p - gam.testing.acc$testingAUC
#   RSS <- sum((pDelta)^2)
#   r2 <- cor(p, gam.testing.acc$testingAUC)^2
#   mse <- sum(RSS) / length(p)
#   gam.imp.acc[i] <- r2
#   
#   additionalName.gam[i] <- predName
# }
# 
# gam.importance <- data.frame(absentName = additionalName.gam, r2.acc = gam.imp.acc, r2.timing = gam.imp)
# 
# 
# gam.importance$acc.reduction <- gam.importance$r2.acc - gam.acc.r2
# gam.importance$timing.reduction <- gam.importance$r2.timing - gam.r2
# 
# 
# gam.importance.plot <- gam.importance[c("timing.reduction", "acc.reduction", "absentName")]
# gam.importance.plot <- melt(gam.importance.plot, id.vars="absentName")
# 
# ggplot(gam.importance.plot) + 
#   geom_bar(aes(x = absentName, y = value, group= variable, fill=variable), 
#            stat='identity', position = "dodge") +
#   ylab("Reduction in Explained Variance") +
#   ggtitle("GAM Model Drivers") + 
#   theme(axis.text.x = element_text(angle = 90)) 
# 
# 


############################################################################################################
####MARS####
############################################################################################################


## Fit the MARS timnig model

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




### Fit the MARS accuracy model
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




### Cross validate to determine model drivers for MARS
additionalName.mars = vector()
mars.imp = vector()
mars.imp.acc = vector()

predNames = vector()
for (i in 1:length(names(mars.training.predictors))){
  predName = names(mars.training.predictors)[i]
  predSet <- mars.training.predictors
  predSet[[predName]] <- NULL
  
  testSet <- mars.testing.predictors
  testSet[[predName]] <- NULL
  
  print(names(testSet))
  print(names(predSet))
  
  ## timing
  model <- bartMachine(predSet, mars.training.response, run_in_sample = F, verbose = FALSE)
  p <- predict(model, testSet)
  pDelta <- p - log(mars.testing$totalTime)
  RSS <- sum((pDelta)^2)
  r2 <- cor(p, log(mars.testing$totalTime))^2
  mse <- RSS / length(p)
  mars.imp[i] <- r2
  
  additionalName.mars[i] <- predName
}

for (i in 1:length(names(mars.training.predictors.acc))){
  predName = names(mars.training.predictors.acc)[i]
  predSet <- mars.training.predictors.acc
  predSet[[predName]] <- NULL
  
  testSet <- mars.testing.predictors.acc
  testSet[[predName]] <- NULL
  
  print(names(testSet))
  print(names(predSet))
  
  ## timing
  model <- bartMachine(predSet, mars.training.response.acc, run_in_sample = F, verbose = FALSE)
  p <- predict(model, testSet)
  pDelta <- p - mars.testing.acc$testingAUC
  RSS <- sum((pDelta)^2)
  r2 <- cor(p, mars.testing.acc$testingAUC)^2
  mse <- sum(RSS) / length(p)
  mars.imp.acc[i] <- r2
  
  additionalName.mars[i] <- predName
}


mars.importance <- data.frame(absentName = additionalName.mars, r2.acc = mars.imp.acc, r2.timing = mars.imp)


mars.importance$acc.reduction <- mars.importance$r2.acc - mars.r2.acc
mars.importance$timing.reduction <- mars.importance$r2.timing - mars.r2


mars.importance.plot <- mars.importance[c("timing.reduction", "acc.reduction", "absentName")]
mars.importance.plot <- melt(mars.importance.plot, id.vars="absentName")

ggplot(mars.importance.plot) + 
  geom_bar(aes(x = absentName, y = value, group= variable, fill=variable), 
           stat='identity', position = "dodge") +
  ylab("Reduction in Explained Variance") +
  ggtitle("MARS Model Drivers") +
  theme(axis.text.x = element_text(angle = 90)) 


############################################################################################################
####RF####
############################################################################################################



### Fit the timing model
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




### Fit the accuracy model
res <- read.csv("thesis-scripts/data/rf_full.csv")
res$seq<- 0
res$seq[res$method == 'SERIAL'] <- 1
res$par <- 0
res$par[res$method == "PARALLEL"] <- 1

rf.testingInd.acc <- sample(nrow(res), nrow(res) * 0.2)
rf.testing.acc <- res[rf.testingInd.acc,]
rf.training.acc <- res[-rf.testingInd.acc,]

rf.training.predictors.acc <- rf.training.acc[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]

rf.training.predictors.acc <- data.frame(rf.training.predictors.acc)
rf.training.response.acc <- rf.training.acc[[c("testingAUC")]] 

rf.acc.rf <- bartMachine(rf.training.predictors.acc, rf.training.response.acc, serialize=T)

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


### Cross validate to evaluate model drivers for RF
# 
# 
# additionalName.rf = vector()
# rf.imp = vector()
# 
# predNames = vector()
# for (i in 1:length(names(rf.training.predictors))){
#   predName = names(rf.training.predictors)[i]
#   predSet <- rf.training.predictors
#   predSet[[predName]] <- NULL
#   
#   testSet <- rf.testing.predictors
#   testSet[[predName]] <- NULL
#   
#   print(names(testSet))
#   print(names(predSet))
#   
#   ## timing
#   model <- bartMachine(predSet, rf.training.response, run_in_sample = F, verbose = FALSE)
#   p <- predict(model, testSet)
#   pDelta <- p - log(rf.testing$totalTime)
#   RSS <- sum((pDelta)^2)
#   r2 <- cor(p, log(rf.testing$totalTime))^2
#   mse <- sum(RSS) / length(p)
#   rf.imp[i] <- r2
#   
#   additionalName.rf[i] <- predName
# }
# 
# rf.imp.acc <- vector()
# for (i in 1:length(names(rf.training.predictors.acc))){
#   predName = names(rf.training.predictors.acc)[i]
#   predSet <- rf.training.predictors.acc
#   predSet[[predName]] <- NULL
#   
#   testSet <- rf.testing.predictors.acc
#   testSet[[predName]] <- NULL
#   
#   print(names(testSet))
#   print(names(predSet))
#   
#   ## timing
#   model <- bartMachine(predSet, rf.training.response.acc, run_in_sample = F, verbose = FALSE)
#   p <- predict(model, testSet)
#   pDelta <- p - rf.testing.acc$testingAUC
#   RSS <- sum((pDelta)^2)
#   r2 <- cor(p, rf.testing.acc$testingAUC)^2
#   mse <- sum(RSS) / length(p)
#   rf.imp.acc[i] <- r2
#   
#   plot(p, rf.testing.acc$testingAUC )
#   
#   additionalName.rf[i] <- predName
# }
# 
# 
# rf.imp.acc <-c(rf.imp.acc, NA, NA)
# 
# rf.importance <- data.frame(absentName = additionalName.rf, r2.acc = rf.imp.acc, r2.timing = rf.imp)
# 
# 
# rf.importance$acc.reduction <- rf.importance$r2.acc - rf.r2.acc
# rf.importance$timing.reduction <- rf.importance$r2.timing - rf.r2
# 
# 
# rf.importance.plot <- rf.importance[c("timing.reduction", "acc.reduction", "absentName")]
# rf.importance.plot <- melt(rf.importance.plot, id.vars="absentName")
# 
# ggplot(rf.importance.plot) + 
#   geom_bar(aes(x = absentName, y = value, group= variable, fill=variable), 
#            stat='identity', position = "dodge") +
#   ylab("Reduction in Explained Variance") +
#   ggtitle("RF Model Drivers") +
#   theme(axis.text.x = element_text(angle = 90)) 

############################################################################################################
####Hypercube Generation####
############################################################################################################

# 
# ## Regular sampling
# learningRateOpts <- seq(0.001, 0.11, by=0.1)
# treeComplexityOpts <- seq(1, 5)
# nTexOpts <- seq(0, 250000, by=5000)
# cellOpts <- seq(10000, 100000, by=100000)
# nPOpts <- seq(1, 5)
# 
# prices <- read.csv("thesis-scripts/data/costs.csv")
# 
# n = length(learningRateOpts) * 
#   length(treeComplexityOpts) *
#   length(nTexOpts) *
#   length(cellOpts) *
#   length(nPOpts) *
#   nrow(prices)
# 
# ## make the hypergrid
# hypercube <- expand.grid(learningRate = learningRateOpts, 
#                          treeComplexity = treeComplexityOpts, 
#                          trainingExamples = nTexOpts, 
#                          cells = cellOpts, 
#                          numPredictors = nPOpts, 
#                          config = unique(prices$ConfigurationNumber),
#                          seconds = 0,
#                          cost = 0,
#                          accuracy = 0)
# 
# 
# ## merge with costs
# timeAndCost <- merge(hypercube, prices, b.x = "config", b.y = "ConfigurationNumber")
# 
# f <- function(i){
#   scenario <- timeAndCost[i, ]
#   logTime <- predict(gbm.rf,  scenario)
#   acc <- predict(gbm.acc.rf, scenario)
#   timePred <- exp(logTime)
#   thisComp.price <- thisComp$TotalRate## this is rate per hour
#   thisComp.pricePerSecond <- thisComp.price / 3600 ## this is rate per second
#   scenarioCost <- timePred * thisComp.pricePerSecond
#   scenario$cost <- scenarioCost
#   scenario$accuracy <- acc
#   scenario$seconds <- timePred
#   return(scenario)
# }
# 
# 
# ## do the prediction, spread out over all cores
# results <- mclapply(1:nrow(timeAndCost), f)
# r <-  data.frame(matrix(unlist(results), ncol=10, nrow=length(results), byrow=T))
# names(r) <- names(results[[1]])
# write.csv(r, "data/timeCost_gbm_all.csv")



nTexOpts <- seq(0, 250000, by=10000)
cellOpts <- seq(10000, 100000, by=100000)
nPOpts <- seq(1, 5)

prices <- read.csv("thesis-scripts/data/costs.csv")

n = length(nTexOpts) *
  length(cellOpts) *
  length(nPOpts) *
  nrow(prices)

## make the hypergrid
hypercube <- expand.grid(trainingExamples = nTexOpts,
                         cells = cellOpts,
                         numPredictors = nPOpts,
                         config = unique(prices$ConfigurationNumber),
                         seconds = 0,
                         cost = 0,
                         accuracy = 0,
                         TotalRate = 0,
                         GBMemory = 0,
                         cores = 0)


## merge with costs
for (value in unique(hypercube$config)){
  rateRow = prices[which(prices$ConfigurationNumber == value), ]
  rate = rateRow$TotalRate
  cores = rateRow$CPUs
  mem = rateRow$GBsMem
  hypercube$ToalRate[hypercube$config == value] = rate
  hypercube$cores[hypercube$config == value] = cores
  hypercube$GBMemory[hypercube$config == value] = mem
}

predictors <- hypercube[c("numPredictors", "cores", "GBMemory", "trainingExamples", "cells")]
names(predictors) <- names(gam.testing.predictors)

library(doParallel)
registerDoParallel(8)


pl <- split(predictors, 1:10)

predictions <-
  foreach(d=1:length(pl),
          .combine=c, .packages=c("stats", "bartMachine")) %dopar% {
            predict(gam.rf, pl[[d]])
          }

predictions.acc <-
  foreach(d=1:length(pl),
          .combine=c, .packages=c("stats", "bartMachine")) %dopar% {
            predict(gam.acc.rf, pl[[d]])
          }

hypercube$seconds <- predictions
hypercube$accuracy <- predictions.acc
hypercube$cost <- hypercube$seconds * (hypercube$TotalRate/3600)
write.csv(hypercube, "data/timeCost_gam_all.csv")
# 
# 
# 



# 


# 
# 

