library(sampling)
library(data.table)
mars <- read.csv("/users/scottsfarley/documents/thesis-scripts/data/mars_full.csv")

m <- data.table(mars)
q <- strata(m, stratanames=c("numPredictors", "trainingExamples", "cells", "cores", "GBMemory"), rep(1, nrow(mars)))
w <- getdata(m, q)
w <- data.table(w)

library(bartMachine)

## sample from MARS full
testingInd <- sample(nrow(mars), nrow(mars) * 0.2)
testing <- mars[testingInd,]

## train with uniques stratified random sample
training <- data.frame(w)
predictors <- training[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
predictors <- data.frame(predictors)
response <- log(training[[c("totalTime")]]) ## take the log for prediction
model <- bartMachine(predictors, response, serialize = T)


## do prediction
testing.predictors <- testing[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
testing.predictors <- data.frame(testing.predictors)
prediction <- predict(model, testing.predictors)

## get statistics
mdCor <- cor(prediction, log(testing[['totalTime']]))
mdDelta <- gbm.prediction - log(testing$totalTime)
mdDelta.mean <- mean(mdDelta)
mdDelta.sd <- sd(mdDelta)
mdDelta.RSS <- sum((mdDelta)^2)
r2 <- mdCor^2
mse <- mdDelta.RSS / length(gbm.prediction)


## Plot
plot(prediction ~ log(testing[['totalTime']]), xlab="Observed", ylab="Predicted", main="Observed-Predicted Execution Time (MARS)")
abline(0, 1)

print(paste("Runtime Model Mean Squared Error: ", mdDelta.RSS/length(prediction)))
print(paste("Runtime Model Percent Variance Explained: ", r2, "%"))

post <- bart_machine_get_posterior(model, testing.predictors)
post <- data.frame(post$y_hat_posterior_samples)
post$sd <- apply(post, 1, sd)

post.sdMean <- mean(post$sd)
print(paste("Runtime Model Posterior Mean Standard Deviation: ", post.sdMean))

### Fit the accuracy model

testingInd.acc <- sample(nrow(mars), nrow(mars) * 0.2)
testing.acc <- mars[testingInd.acc,]
training.acc <- training ## use stratified random sample

training.predictors.acc <- training.acc[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
training.predictors.acc <- data.frame(training.predictors.acc)
training.response.acc <- training.acc[[c("testingAUC")]] 

acc.model <- bartMachine(training.predictors.acc, training.response.acc, serialize=T)

## do prediction
testing.predictors.acc <- testing.acc[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
testing.predictors.acc <- data.frame(testing.predictors.acc)
prediction.acc <- predict(acc.model, testing.predictors.acc)

## get statistics
## get statistics
mdCor.acc <- cor(prediction.acc, testing.acc[['testingAUC']])
mdDelta.acc <- prediction.acc - testing.acc[[c("testingAUC")]] 
mdDelta.mean.acc <- mean(mdDelta.acc)
mdDelta.sd.acc <- sd(mdDelta.acc)
mdDelta.RSS.acc <- sum((mdDelta.acc)^2)
r2.acc <- mdCor.acc^2
mse.acc <- mdDelta.RSS.acc / length(prediction.acc)

## Plot
plot(prediction.acc ~ testing.acc[['testingAUC']], xlab="Observed AUC", 
     ylab="Predicted AUC", main="Observed-Predicted AUC (MARS)")
abline(0, 1)

print(paste("Accuracy Model Mean Squared Error: ", mse.acc))
print(paste("Accuracy Model Percent Variance Explained: ", r2.acc, "%"))

post.acc <- bart_machine_get_posterior(acc.model, testing.predictors.acc)
post.acc <- data.frame(post.acc$y_hat_posterior_samples)
post.acc$sd <- apply(post.acc, 1, sd)

post.sdMean.acc <- mean(post.acc$sd)
print(paste("Accuracy Model Posterior Mean Standard Deviation: ", post.sdMean.acc))

### Cross validate model drivers
additionalName = vector()
model.imp = vector()
model.r2 = vector()

for (i in 1:length(names(predictors))){
  predName = names(predictors)[i]
  predSet <- predictors
  predSet[[predName]] <- NULL
  
  testSet <- testing.predictors
  testSet[[predName]] <- NULL
  
  print(names(testSet))
  print(names(predSet))
  
  ## timing
  model <- bartMachine(predSet, response, run_in_sample = F, verbose = FALSE)
  p <- predict(model, testSet)
  pDelta <- p - log(testing$totalTime)
  RSS <- sum((pDelta)^2)
  r2 <- cor(p, log(testing$totalTime))^2
  mse <- sum(RSS) / length(p)
  model.imp[i] <- mse
  model.r2[i] <- r2
  
  additionalName[i] <- predName
}

imp.acc <- vector()
acc.r2 <- vector()
for (i in 1:length(names(training.predictors.acc))){
  predName = names(training.predictors.acc)[i]
  predSet <- training.predictors.acc
  predSet[[predName]] <- NULL
  
  testSet <- testing.predictors.acc
  testSet[[predName]] <- NULL
  
  print(names(testSet))
  print(names(predSet))
  
  ## timing
  model <- bartMachine(predSet, training.response.acc, run_in_sample = F, verbose = FALSE)
  p <- predict(model, testSet)
  pDelta <- p - testing.acc$testingAUC
  RSS <- sum((pDelta)^2)
  r2 <- cor(p, testing.acc$testingAUC)^2
  mse <- RSS / length(p)
  imp.acc[i] <- mse
  acc.r2[i] <- r2
  
  additionalName[i] <- predName
}

importance <- data.frame(absentName = additionalName, mse.acc = imp.acc, mse.timing = model.imp, r2=model.r2, r2.acc = acc.r2)


importance$acc.reduction <- importance$mse.acc - mse.acc
importance$timing.reduction <- importance$mse.timing - mse
importance$acc.r2.reduction <- importance$r2.acc - r2.acc
importance$r2.reduction <- importance$r2 - r2


importance.plot <- importance[c("timing.reduction", "acc.reduction", "absentName")]
importance.plot <- melt(importance.plot, id.vars="absentName")

ggplot(importance.plot[importance.plot$variable == "timing.reduction", ]) + 
  geom_bar(aes(x = absentName, y = value, group= variable, fill=variable), 
           stat='identity', position = "dodge") +
  ylab("Reduction in Explained Variance") +
  ggtitle("MARS Model Drivers") +
  theme(axis.text.x = element_text(angle = 90)) 

ggplot(importance.plot[importance.plot$variable == "acc.reduction", ]) + 
  geom_bar(aes(x = absentName, y = value, group= variable, fill=variable), 
           stat='identity', position = "dodge") +
  ylab("Reduction in Explained Variance") +
  ggtitle("MARS Model Drivers") +
  theme(axis.text.x = element_text(angle = 90)) 

write.csv(training, file='/users/scottsfarley/documents/thesis-scripts/data/MARS_reduced.csv')
