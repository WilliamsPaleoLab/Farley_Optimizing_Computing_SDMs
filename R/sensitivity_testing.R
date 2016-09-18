library(randomForest)
library(reshape2)
library(gam)
setwd("/users/scottsfarley/documents")
res <- read.csv("thesis-scripts/data/rf_full.csv")

res <- res[c("totalTime", "cores", "GBMemory", "trainingExamples", "numPredictors", "cells")]
res <- scale(res)
res <- data.frame(res)
rf <- gam(totalTime ~ cores + GBMemory + trainingExamples + numPredictors + cells, data=res, ntree=1000)

# 
# trainingExampleDF <- data.frame(
#   cores = vector('numeric', length=20000),
#   GBMemory = vector('numeric', length=20000),
#   trainingExamples = vector('numeric', length=20000),
#   numPredictors = vector('numeric', length=20000),
#   modeledTime = vector('numeric', length=20000)
# )
# 
# 
# 
# l <- vector()
# for (i in 1:20000){
#   scenario <-  c(cores = as.numeric(meanCores), GBMemory = as.numeric(meanGBMem),
#                  trainingExamples = i,
#                  numPredictors = as.numeric(meanNumPred))
#   modeledTime <- predict(rf, t(scenario))
#   row <- c(scenario, modeledTime)
#   trainingExampleDF[i, ] <- row
#   l[[i]] <- modeledTime
# }
# 

samp1 <- res[sample(nrow(res), 10000),]
samp2 <- res[sample(nrow(res), 10000),]


sens <- sobol(rf, samp1, samp2, order=2, nboot=100)


