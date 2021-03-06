---
  title: "Optimization Routines"
output:
  html_document:
  highlight: tango
theme: spacelab
toc: no
pdf_document:
  toc: yes
---
  
  ## Approach
  ### Uncontrained Optimization
  
  1. Use a combination of prediction and interpolation to predict all values oftime and accuracy under different hardware/software configurations.
2. Find the minimal combination of algorithm inputs that maximize accuracy. If there are ties, break them by using the point that requires the least data.
3. Find the costs associated with running the algorithm with those inputs on all different hardware configurations.
4. Find the combination of hardware that jointly minimizes cost and time.

### Data-contrained Optimization
1.  Use a combination of prediction and interpolation to predict all values oftime and accuracy under different hardware/software configurations.
2.  Subset the accuracy surface produced above to the amount of data available.  The maximizing point will fall in the upper right corner of the subsetted space.
3.  Find the costs associated with running the algorithms with the accuracy-maximizing point on all different hardwares.
4.  Find the combination of hardware that jointly minimizes time and cost.

### Cost-constrained Optimization
1.  Use a combination of prediction and interpolation to predict all values oftime and accuracy under different hardware/software configurations.
2.  Subset the space produced above to the amount of time and money able to be spent on modelling.  
3.  Working backwards now, find the accuracies that can be produced in the limited time.
4.  Using the subset of accuracy space, find the combination of algorithm inputs that maximizes accuracy.

```{r setup}
knitr::opts_chunk$set(cache=TRUE, echo=F, warning=F, error = F, message=F)
knitr::opts_knit$set(root.dir = "/users/scottsfarley/documents")
setwd("/users/scottsfarley/documents")
library(parallel)
library(doParallel)
library(akima)
library(ggplot2)
options(java.parameters = "-Xmx1500m")
library(bartMachine)
bartMachine::set_bart_machine_num_cores(3)
library(reshape2)

threshold.time <- 22 ##seconds
threshold.cost <- 30 ##cents
threshold.numTex <- 45
```


First, get the training data and fit the model.  Perform some skill checks on it.
```{r modelFitting}
res <- read.csv("thesis-scripts/data/gam_full.csv")
predictors <- res[c( "numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
predictors <- data.frame(predictors)
response <- log(res[[c("totalTime")]]) ## take the log for prediction
GAM.rf <- bartMachine(predictors, response, serialize=T, verbose = T, run_in_sample = F)

predictors.acc <- res[c("numPredictors", "cores", "GBMemory", "trainingExamples", 'cells')]
predictors.acc <- data.frame(predictors.acc)
response.acc <- res[[c("testingAUC")]] 

GAM.acc.rf <- bartMachine(predictors.acc, response.acc, serialize=T, verbose=T, run_in_sample = F)

```



Choose a finite number of possible solutions to the model.  Ideally, we would want every single combination of predictor variables [0, Inf].  This is obviously intractable.  Moreover, I only have data for a subset of that space anyways.  So randomly sample the subspace in which I have data to make the problem possible to solve.

```{r subset}
cores <- seq(1, 10)
GBMemory <- seq(1, 10)
trainingExamples <- seq(0, 10000, by=1000)
numPredictors <- seq(1, 5)
cells <- 100000

prices <- read.csv("/users/scottsfarley/documents/thesis-scripts/data/costs.csv")

## make the hypergrid
scenario <- expand.grid(numPredictors = numPredictors,
                        # cores = cores,
                        # GBMemory = GBMemory,
                        trainingExamples = trainingExamples,
                        cells = cells,
                        config = unique(prices$ConfigurationNumber))

for (value in unique(scenario$config)){
  rateRow = prices[which(prices$ConfigurationNumber == value), ]
  rate = rateRow$TotalRate
  cores = rateRow$CPUs
  mem = rateRow$GBsMem
  scenario$TotalRate[scenario$config == value] = rate
  scenario$cores[scenario$config == value] = cores
  scenario$GBMemory[scenario$config == value] = mem
}
```


Using that subset of data and the models we fit previously, predict each candidate configuration of algorithm inputs and hardware variables for execution time and SDM accuracy.
```{r}
scenario.acc <- scenario[c("numPredictors", "trainingExamples", "cells", 
                           "cores", "GBMemory")]
p.acc <- predict(GAM.acc.rf, scenario.acc)


scenario.time <- scenario[c("numPredictors", "trainingExamples", "cells", "cores", "GBMemory")]
## split here because my computer is stupid and runs out of heap space
p.time.1 <- predict(GAM.rf, scenario.time)
p.time <- c(p.time.1)
scenario$accuracy <- p.acc
scenario$seconds <- exp(p.time)
scenario$cost <- scenario$seconds * scenario$TotalRate
```

Plot the posterior means of the accuracy models against the algorithm inputs that should control accuracy. In this case, these are number of training examples and number of covariates.
```{r plotAccuracy}
i.acc <- interp(x = scenario$numPredictors, 
                y = scenario$trainingExamples, 
                z = scenario$accuracy, 
                xo = seq(1, 5),
                yo = seq(1, 10000),
                duplicate=T)

i.acc <- interp2xyz(i.acc, data.frame = T)


# ggplot(i.acc, aes(x, y, z = z)) +
#   geom_tile(aes(fill=z), height=1, width=1) +
#   stat_contour(binwidth=0.05, col='black', lwd=0.25) +
#   ggtitle("Random Forest Accuracy Surface") +
#   xlab("Number of Covariates") +
#   ylab("Number of Training Examples") +
#   scale_fill_continuous(low='pink', high='forestgreen')
```


The accuracy clearly varies from low (few training examples and few covariates) to very high (many covariates, many training examples).  Perhaps more data would be helpful here, but what are you going to do. Our task is to find the combinations of inputs that results in the highest accuracy model. If there's a tie, find the combination that needs the least data.    

Now, we know the combination of algorithm inputs that result in the highest accuracy.  The figure below shows the combination identified on the training examples and covariates axes.  This combination of training examples and number of covariates can be run on any combination of hardware.  Some might be suboptimal.  Thus, at this point, we've solved half of our challenge: algorithm inputs have been optimized, now it's time optimize hardware.


```{r checkHardwareEffect}
### select the combination that has the highest accuracy
## order by the things that control accuracy
## first by training examples, then by num predictors
## select the highest accuracy with the lowest valued predictors
sortedScenario <- i.acc[order(i.acc$y, i.acc$x),]
maxID <- which.max(sortedScenario$z)
theMax <- sortedScenario[maxID, ]
print(paste("Accuracy is maximized at", theMax$y, "training examples and", theMax$x, "predictors."))

theMax.trainingExamples <- theMax$y
theMax.numPredictors <- theMax$x
theMax.expectedAccuracy <- theMax$z
theMaxSet <- scenario[scenario$trainingExamples == theMax.trainingExamples &
scenario$numPredictors == theMax.numPredictors, ]


names(i.acc) <- c("numPredictors", "trainingExamples", "accuracy")
## plot the max onto the surface from before
ggplot(i.acc, aes(numPredictors, trainingExamples, z = accuracy)) +
geom_tile(aes(fill=accuracy), height=1, width=0.5) +
stat_contour(binwidth=0.01, col='black') +
ggtitle("Random Forest Accuracy Surface") +
xlab("Number of Covariates") +
ylab("Number of Training Examples") +
scale_fill_continuous(low='pink', high='forestgreen') +
geom_point(data=theMaxSet, aes(x = numPredictors , y = trainingExamples), shape=25, fill='red', size=3)
```

In theory, the hardware parameters should not affect the SDM accuracy.  We can test this assumption here, by plotting the accuracies obtained for this combination of algorithm inputs against modeled accuracy on the number of CPUs and amount of memory.  If the assumption is valid, the plot should show no change in either the horizontal or vertical directions.  We see that there is, in fact, some change, though.  This is likely due to expeirmental design, and lack of a full factorial design setup.  The effect is realtively minor, and I choose to comment it and move along. 

```{r accAssumptionCheck}
ggplot(theMaxSet) +
geom_tile(aes(x = cores, y=GBMemory, z=accuracy, fill=accuracy)) +
#geom_contour(aes(x = cores, y=GBMemory, z=accuracy, fill=accuracy)) +
ggtitle("Random Forest Hardware/Accuracy Surface") +
xlab("CPU Cores") +
ylab("RAM (GB)") +
scale_fill_continuous(low='blue', high='red')

acc.diff <- max(theMaxSet$accuracy) - min(theMaxSet$accuracy)
acc.diffFromExp <- mean(theMaxSet$accuracy) - theMax.expectedAccuracy
print(paste("Accuracy Range on Hardware: ", acc.diff))
print(paste("Accuracy Range from Expectation: ", acc.diffFromExp))
print(paste("Model Posterior Mean Standard Deviation: ", rf.post.acc.sdMean))

print("------")
print(paste("Fixing accuracy at: ", theMax.expectedAccuracy))
```

Now, fix the algorithm inputs at the accuracy-maximizing point-- effectively fixing expected model accuracy.  An algorithm with these inputs can be run on any combination of hardware. Project how long that specific model would take and how much it would cost on all computing types.  Plot those out on time vs. cost axes.

```{r timeCostProjection}
ggplot(theMaxSet) +
geom_point(aes(x = cores, y = GBMemory))+
ggtitle("Random Forest Time/Cost Surface for Accuracy-Maximizing Point") +
xlab("Cost (cents)") +
ylab('Cost (seconds)') 
```

```{r timeCostProjection}
ggplot(theMaxSet) +
geom_point(aes(x = cost, y = seconds))+
ggtitle("Random Forest Time/Cost Surface for Accuracy-Maximizing Point") +
xlab("Cost (cents)") +
ylab('Cost (seconds)') 
```

The optimal solution is the one that balances time and cost equally during the minimization. We use euclidean distance here, which normalizes each dimension by its standard deviation, so they are weighted equally. For each candidate combiantion of hardware, we calculate the distance between it and the origin of these two axes.  We then find the minimum of that distance matrix and call that point the optimal.

```{r distCalc}
origin <- rep(0, length(theMaxSet))
pointSet <- theMaxSet[c("seconds", "cost")]
candidates <- rbind(pointSet, origin)
d <- as.matrix(dist(candidates))
fromOrigin <- d[,nrow(candidates)]
fromOrigin <- fromOrigin[fromOrigin > 0]
fromOrigin <- as.numeric(fromOrigin)
minDistIdx <- which.min(fromOrigin)
optimal <- theMaxSet[minDistIdx, ]

optimalDist <- min(fromOrigin)

xend = optimal$seconds
yend = optimal$cost
## Plot the same thing, but now with the optimal marked
ggplot(theMaxSet) +
geom_point(aes(x = cost, y = seconds)) +
ggtitle("Random Forest Time/Cost Surface") +
xlab("Cost (cents)") +
ylab('Cost (seconds)')  +
geom_segment(data=theMaxSet, aes(x = 0, y=0, xend=cost, yend=seconds), alpha=0.075) +
geom_point(data=optimal, aes(x = cost, y = seconds), col='red', size=3, shape=25)

```

```{r}
fromOrigin <- data.frame(fromOrigin)


ggplot(fromOrigin) + geom_histogram(aes(x=fromOrigin), binwidth=5) +
ggtitle("Histogram of Distances from the Origin") +
xlab("Euclidean Distance from the Origin") +
ylab("Point-Count")
```

Our job is complete. We've now optimized both the harware and software dimensions of the problem. 

```{r printRes}
print("------RANDOM FOREST OPTIMAL--------")
print(paste("Predicted Optimal Accuracy", theMax.expectedAccuracy, "+/-", abs(acc.diffFromExp)))
print(paste("Predicted Optimal Cost (seconds)", optimal$seconds))
print(paste("Predicted Optimal Cost (cents)", optimal$cost))
print(paste("Cores: ", optimal$cores))
print(paste("Memory:", optimal$GBMemory))
print(paste("Training Examples:", theMax.trainingExamples))
print(paste("Covariates:", theMax.numPredictors))
```

Everything up to this point was done using the mean of the posterior distribution, a choice which simplifies the process but causes some information loss and may cause over-confidence in the predictions. We can modify our steps to include information from the entire posterior, which may solve this issue.  

```{r bayesSetup}
theMaxSet.time <- theMaxSet[c("numPredictors", "trainingExamples", "cells", "cores", "GBMemory")]
theMaxSet.time$par <- 1
theMaxSet.time$seq <- 0
time.post <- bart_machine_get_posterior(GAM.rf, theMaxSet.time)$y_hat_posterior_samples
time.post <- data.frame(time.post)
time.post$cores <- theMaxSet$cores
time.post$GBMemory <- theMaxSet$GBMemory
time.post$config <- theMaxSet$config
time.post$TotalRate <- theMaxSet$TotalRate
```

Instead of projecting just the mean time and mean cost for use the the distance minimization, use the entire set of posterior samples.  Calculate the distance metric for each sample in the posterior independently.  You're then left with a density distribution of distances, from which we can infer the minimum value.

```{r}
library(plyr)
time.post$postMeanTime <- rowMeans(time.post[, 1:1000])
time.post$postMeanTime <- exp(time.post$postMeanTime)
time.post$postMeanCost <- time.post$postMeanTime * time.post$TotalRate

ggplot(time.post) + 
geom_point(aes(x = postMeanCost, y = postMeanTime), shape=20, col='green', size=2) +
geom_point(data = theMaxSet, aes(x = cost, y = seconds), col='blue', size=2, shape=25)

```

```{r plot}
## get the data frame ready for plotting
c.d <- melt(time.post, id.vars = c("cores", "GBMemory", "config", "TotalRate", "postMeanTime", "postMeanCost"))
c.d <- na.omit(c.d)
c.d$value <- exp(c.d$value)
c.d$CostSample <- c.d$value * c.d$TotalRate
c.d$config <- as.factor(c.d$config)
ggplot(c.d) +
geom_point(aes(x = CostSample, y = value, col=config), alpha=0.05) +
scale_color_discrete(guide=F) +
geom_point(data=time.post, aes(x = postMeanCost, y = postMeanTime), shape=20, size=2) +
ggtitle("Time/Cost Posterior Estimates") +
xlab("Cost") +
ylab("Time")
```

The posteriors are in a line, since there's a fixed linear relationship between time and cost.

Now, find the distance metrics for all of those points.

```{r}
### okay, so we've got the posteriors for time and cost, now we can use them in calculating the optimal distnace

compDists <- list()
for (i in 1:nrow(time.post)){ ## all of the candidates in theMaxSet
  compDist <- vector()
  thisRate <- as.numeric(as.character(theMaxSet$TotalRate[i]))
  for (j in 1:1000){ ## 1000 posterior samples
    t.i <- exp(time.post[[j]][[i]]) ## psoterior of time for this config
    c.i <- t.i * thisRate ## make cost posterior from time samples times rate
    pt <- c(t.i, c.i)
    orig <- c(0, 0)
    m <- rbind(pt, orig)
    d <- as.matrix(dist(m))
    d <- d[d > 0]
    d <- as.numeric(d)
    compDist[j] <- d[[1]]
  }
  compDists[[i]] <- compDist
}

allDistances <- melt(compDists)

p <- na.omit(allDistances)
p$value <- as.numeric(p$value)
p$L1 <- as.factor(p$L1)
ggplot(p) + 
  geom_density(aes(x=value, group=L1, col=L1), alpha=0.025) +
  scale_fill_brewer('Dark2', guide=FALSE) + guides(colour=FALSE, L1=F) +
  xlab("Euclidiean Distance From Origin") +
  ggtitle("Euclidean Distance From Origin of Posterior") +
  geom_rug(aes(x= fromOrigin), data=fromOrigin, lwd=0.25, alpha=0.5)
```

There's a lot of overlab in this figure, and many points are far away from the optimal.  We don't care about those.  Take the few closest to the minimum and look at their distributions. 

```{r minimalDistributions}
post.timeCost.sorted <- p[order(p$value),]
candidates <- unique(post.timeCost.sorted$L1)[1:25]

candidateMeans <- data.frame(fromOrigin$fromOrigin[candidates]) ## the means for each candidate distribution
names(candidateMeans) <- c("CandidateMeans")
candidateMeans$L1 <- candidates

## select their whole distributions
candidate.dist <- post.timeCost.sorted[post.timeCost.sorted$L1 %in% candidates, ]
ggplot(candidate.dist) + 
  geom_density(aes(x=value, group=L1, col=L1), alpha=0.2) +
  scale_fill_brewer('Dark2', guide=FALSE) + guides(colour=FALSE, L1=F) +
  xlab("Euclidiean Distance From Origin") +
  ggtitle("Density of Euclidean Distance From Origin") +
  # geom_rug(aes(x =value , group=L1, col=L1), alpha=0.025) +
  geom_rug(data=candidateMeans, aes(x = CandidateMeans, col=L1)) +
  xlim(0, 200) +
  geom_vline(xintercept = optimalDist, col='black', lwd=0.5)



```

Now, the optimal configuration may be one of the following:
  
  ```{r minimalDistTable}
candidateConfigs <- theMaxSet[theMaxSet$config %in% candidates, ]
library(plyr)
distStats <- ddply(allDistances, .(L1), summarise, meanDist = mean(value), sdDist = sd(value))
candidateDists <- distStats[distStats$L1 %in% candidates, ]
candidateConfigs$distance.mean = candidateDists$meanDist
candidateConfigs$distance.sd = candidateDists$sdDist
candidateConfigs <- candidateConfigs[c("config", "cores", "GBMemory", "seconds", "cost", "distance.mean", "distance.sd")]
candidateConfigs <- candidateConfigs[order(candidateConfigs$distance.mean, candidateConfigs$distance.sd), ]
library(knitr)
kable(candidateConfigs, row.names = F)
```

In the results above, you're accutally seeing the trade off between time and money play out quite nicely.  Adding cores costs money, but, in the case of random forests, reduces time. Here, that tradeoff basically exactly evens out.


### Cost-Constrained Optimization
There are two main types of constraints on this optimization problem: (1) limited time and/or money and (2) limited data.  In the first case, the researcher only has so much time or money (or both) available to be spent on modelling.  She must optimize her workflow so that she can get the most out of the limited funds she has available to her. For one experiment, this doesn't really hold water, since there are only cents and seconds being spent on computing the models. However, when think about global syntheses with many species, these add up to be significant expenditures.  

In this simple example, the researcher has a hard maximum of 10 seconds and 25 cents to be spent on the model.

First, calculate a surface of all the possible configurations, whether or not they meet her threshold.

Now, subset that surface, retaining only the configurations that satisfy her threshold in time and in money. Find the maximum amount of data that can be used, and calculate all the possible accuracies that could be achieved using it.  This down-weights expensive computing types, and encourages the solution to have a high accuracy.

```{r}

## interpolate time as a function of algorithm inputs
time.interp <- interp(x = scenario$trainingExamples, 
                      y = scenario$numPredictors, 
                      z = scenario$seconds, 
                      xo = seq(1, 10000),
                      yo = seq(1, 5),
                      duplicate=T)
time.interp <- interp2xyz(time.interp, data.frame=T)
names(time.interp) <- c("trainingExamples", "numPredictors", "seconds")

## interpolate cost as a function of algorithm inputs
cost.interp <- interp(x = scenario$trainingExamples, 
                      y = scenario$numPredictors, 
                      z = scenario$cost, 
                      xo = seq(1, 10000),
                      yo = seq(1, 5),
                      duplicate=T)
cost.interp <- interp2xyz(cost.interp, data.frame=T)
names(cost.interp) <- c("trainingExamples", "numPredictors", "cost")

time.interp$cost <- cost.interp$cost

ggplot() +
  geom_tile(aes(x = numPredictors, y = trainingExamples, fill = seconds), data=time.interp) +
  # geom_contour(aes(x = numPredictors, y = trainingExamples, z = seconds), binwidth=1, data = time.interp, col='red') +
  scale_fill_continuous(low='darkblue', high='red') +
  ggtitle("Algorithm Input's Influence Execution Time") +
  xlab("Number of Covariates") +
  ylab("Number of Training Examples")



## find only the combinations of algorithm inputs that will result in a time/cost under the threshold
i.subset <- time.interp[time.interp$cost < threshold.cost & time.interp$seconds < threshold.time, ]

if(nrow(i.subset) == 0){
  warning("There are no candidate solutions within your thresholds.")
}else{
  print(paste("There are ", nrow(i.subset), "candidates."))
}

## interpolate accuracies on the same combinations of inputs
i.acc <- interp(x = scenario$numPredictors,
                y = scenario$trainingExamples,
                z = scenario$accuracy,
                xo=seq(1, 5),
                yo = seq(0, 10000),
                duplicate = T)
i.acc <- interp2xyz(i.acc, data.frame=T)
names(i.acc) <- c("numPredictors", "trainingExamples", "accuracy")

## group into combinations of algorithm input
i.acc$grp <- interaction(i.acc$numPredictors, i.acc$trainingExamples)
i.subset$grp <- interaction(i.subset$numPredictors, i.subset$trainingExamples)


## select only accuracies that can be achieved within time and cost
i.acc.subset <- i.acc[i.acc$grp %in% i.subset$grp, ]

```

Notice the change is scales.  We're not able to get to a point with more than 4000 training examples now.  Instead, we've limited to low data, and lower accuracy, because of the time/money constraint.

```{r}
sortedScenario <- i.acc.subset[order(i.acc.subset$trainingExamples,
                                     i.acc.subset$numPredictors),]
maxID <- which.max(sortedScenario$accuracy)
theMax <- sortedScenario[maxID, ]
print(paste("Accuracy is maximized at", theMax$trainingExamples, "training examples and", theMax$numPredictors, "predictors."))

## select all of the different ways in which that accuracy could be achieved.
## in this case, there should only be one
## there should only be one point with both the maximum number of examples and covariates
theMaxSet <- i.acc.subset[i.acc.subset$trainingExamples == theMax.trainingExamples &
                            i.acc.subset$numPredictors == theMax.numPredictors, ]


## plot the max onto the surface from before
ggplot(i.acc.subset, aes(numPredictors, trainingExamples, z = accuracy)) +
  geom_tile(aes(fill=accuracy), height=1, width=0.5) +
  ggtitle("Random Forest Accuracy Surface") +
  xlab("Number of Covariates") +
  ylab("Number of Training Examples") +
  scale_fill_continuous(low='pink', high='forestgreen') +
  geom_point(data=theMaxSet, aes(x = numPredictors , 
                                 y = trainingExamples), shape=25, fill='red', size=3)


print(paste("Expected accuracy in this scenario is: ", theMax$accuracy))
print(paste("Fixing training examples at: ", theMax$trainingExamples))
print(paste("Fixing covariates at: ", theMax$numPredictors))
```

```{r}

## interpolate time to all combinations of hardware
i.time <- interp(x = scenario$cores, 
                 y = scenario$GBMemory, 
                 z = scenario$seconds, 
                 xo = seq(1, 22),
                 yo = seq(1, 22, by=0.25),
                 duplicate=T)
i.time <- interp2xyz(i.time, data.frame=T)
names(i.time) <- c("Cores", "GBMemory", "Seconds")

## group into combinations of hardware
i.time$config <- interaction(i.time$Cores, i.time$GBMemory)

## get the rate for each combination
i.time$TotalRate <- 0
for (value in levels(i.time$config)){ ## value is the group factor label
  testRow <- i.time[which(i.time$config == value), ] ## select the rows with this combination of inputs
  testCores <- round(testRow$Cores) 
  testGB <- round(testRow$GBMemory)
  rateRow = prices[which(prices$CPUs == testCores & prices$GBsMem == testGB), ] ## get the rate for that group from GCE pricing
  rate = rateRow$TotalRate 
  if(is.null(rate)){
    rate = 0
  }
  if(length(rate) == 0){
    rate = 0
  }
  i.time$TotalRate[i.time$config == value] = rate ## assign the rate to that group
}


## this is every possible combination of hardware and its rate
i.time$cost <- i.time$TotalRate * i.time$Seconds

```


```{r}
## subset the combinations of hardware to those that can complete the accuracy-maximizing combination under budget
scenarioOut <- list()
idx = 1

## group accuracy based on algorithm inputs
i.acc$grp <- interaction(i.acc$trainingExamples, i.acc$numPredictors)

## group scenario (actual data points, not interpolated) by hardware
scenario$grp <- interaction(scenario$cores, scenario$GBMemory)

scenarioOut <- data.frame(grp = vector(), cost=vector(), seconds=vector())
for (value in levels(scenario$grp)){ ## for each hardware
  try({
    thisSubset <- scenario[scenario$grp == value, ] ## subset the actual data points to those with this iteration's hardware combination
    ## using only those data points, interpolate the time for all possible combinations of input
    this.timeInterp <- interp(x = thisSubset$trainingExamples,
                              y = thisSubset$numPredictors, 
                              z = thisSubset$seconds, duplicate = T, xo= seq(0, 10000, by=1), yo=seq(1,5))
    ## and for cost
    this.costInterp <- interp(x = thisSubset$trainingExamples,
                              y = thisSubset$numPredictors, 
                              z = thisSubset$cost, duplicate = T, xo= seq(0, 10000, by=1), yo=seq(1,5))
    
    ## combine time and cost into a single data frame
    this.timeInterp <- interp2xyz(this.timeInterp, data.frame=T)
    this.costInterp <- interp2xyz(this.costInterp, data.frame=T)
    names(this.timeInterp) <- c("trainingExamples", "numPredictors", "seconds")
    names(this.costInterp) <- c("trainingExamples", "numPredictors", "cost")
    
    this.timeCostInterp <- this.timeInterp
    this.timeCostInterp$cost <- this.costInterp$cost
    
    ## here's the import parts
    # 1. subset the interpolated time surface to give only the experiments that fall within budget
    this.timeCost.subset <- this.timeCostInterp[this.timeCostInterp$seconds < threshold.time &
                                                  this.timeCostInterp$cost < threshold.cost, ]
    
    # 2. Out of the experiments that fall within budget, select the accuracy-maximizing point
    maxSubset <- this.timeCost.subset[this.timeCost.subset$trainingExamples == theMax$trainingExamples &
                                        this.timeCost.subset$numPredictors == theMax$numPredictors, ]
    ## recor in the data frame that it is possible to compute this accuracy under budget on this hardware
    maxSubset$grp <- value ## CPU/Memory grouping
    scenarioOut[idx, ] <- maxSubset[c("grp", "cost", "seconds")] ## we've already put it into time/cost terms here
    idx = idx + 1
    
  })
}
write.csv(scenarioOut, file="thesis-scripts/data/rf_so.csv")

## split the factor of hardware grouping apart, so we can use them later
scenarioOut$cores <- sapply(strsplit(as.character(scenarioOut$grp), "\\."), "[", 1)
scenarioOut$GBMemory <- sapply(strsplit(as.character(scenarioOut$grp), "\\."), "[", 2)

```


Finally, come back around, and find the computing hardware that's best for these inputs.
```{r}
## now, we've got a set of computing types that are capable of achieving the accuracy maximizing point under budget
## find the point that minimizes time and cost
## just like before
origin <- rep(0, length(scenarioOut))
pointSet <- scenarioOut[c("seconds", "cost")]
candidates <- rbind(pointSet, origin)
d <- as.matrix(dist(candidates))
fromOrigin <- d[,nrow(candidates)]
fromOrigin <- fromOrigin[fromOrigin > 0]
fromOrigin <- as.numeric(fromOrigin)
minDistIdx <- which.min(fromOrigin)
optimal <- scenarioOut[minDistIdx, ]

optimalDist <- min(fromOrigin)

xend = optimal$seconds
yend = optimal$cost

print(paste("Now there are only: ", nrow(scenarioOut), "candidates, instead of ", nrow(prices), "candidates that can complete this scenario under budget."))

## Plot the same thing, but now with the optimal marked
ggplot(scenarioOut) +
  geom_point(aes(x = cost, y = seconds)) +
  ggtitle("Random Forest Time/Cost Surface") +
  xlab("Cost (cents)") +
  ylab('Cost (seconds)')  +
  geom_segment(aes(x = 0, y=0, xend=cost, yend=seconds), alpha=0.075) +
  geom_point(data=optimal, aes(x = cost, y = seconds), col='red', size=3, shape=25)

print(paste("Recommended # cores: ", optimal$cores))
print(paste("Recommended Memory: ", optimal$GBMemory))
print(paste("Expected Cost: ", optimal$cost))
print(paste("Expected Seconds: ", optimal$seconds))
```


### Data Constraint

In this case, we've got a constraint on the amount of data available to us. 

```{r}

## interpolate accuracy, as before
i.acc <- interp(x = scenario$numPredictors, 
y = scenario$trainingExamples, 
z = scenario$accuracy, 
xo = seq(1, 5),
yo = seq(1, 10000),
duplicate=T)

i.acc <- interp2xyz(i.acc, data.frame = T)


## subset accuracy interpolation to only include those with data satisfying the constraint
names(i.acc) <- c("numPredictors", "trainingExamples", "accuracy")
i.acc.subset <- i.acc[i.acc$trainingExamples < threshold.numTex, ]
# i.acc.subset.plot <- i.acc
# i.acc.subset.plot$accuracy[i.acc.subset.plot$trainingExamples > threshold.numTex] <- NA
#   
# ggplot(i.acc.subset.plot, aes(numPredictors, trainingExamples, z = accuracy)) +
#   geom_tile(aes(fill=accuracy), height=1, width=0.5) +
#   stat_contour(binwidth=0.05, col='black') +
#   ggtitle("Random Forest Accuracy Surface") +
#   xlab("Number of Covariates") +
#   ylab("Number of Training Examples") +
#   scale_fill_continuous(low='pink', high='forestgreen') 

print(paste("Current data threshold is ", threshold.numTex))
```

```{r}

## find, from the subsetted accuracies, the combinations of inputs that maximize accuracy
sortedScenario <- i.acc.subset[order(i.acc.subset$trainingExamples, i.acc.subset$numPredictors),]
maxID <- which.max(sortedScenario$accuracy)
theMax <- sortedScenario[maxID, ]
print(paste("Accuracy is maximized at", theMax$trainingExamples, "training examples and", theMax$numPredictors, "predictors."))
print(paste("Expected Max Accuracy is ", theMax$accuracy))
```

```{r}


## now do the same inverse problem we did before
## using the accuracy, find out how long each will take to compute
scenarioOut <- list()
idx = 1

i.acc$grp <- interaction(i.acc$trainingExamples, i.acc$numPredictors)
i.acc.subset <- i.acc[i.acc$trainingExamples < threshold.numTex, ] ## subset to limited data


scenario$grp <- interaction(scenario$cores, scenario$GBMemory)

scenarioOut <- data.frame(grp = vector(), cost=vector(), seconds=vector())
for (value in levels(scenario$grp)){ ## for each hardware
try({
thisSubset <- scenario[scenario$grp == value, ]
this.timeInterp <- interp(x = thisSubset$trainingExamples,
y = thisSubset$numPredictors, 
z = thisSubset$seconds, duplicate = T, xo= seq(0, 10000, by=1), yo=seq(1,5))
this.costInterp <- interp(x = thisSubset$trainingExamples,
y = thisSubset$numPredictors, 
z = thisSubset$cost, duplicate = T, xo= seq(0, 10000, by=1), yo=seq(1,5))
this.timeInterp <- interp2xyz(this.timeInterp, data.frame=T)
this.costInterp <- interp2xyz(this.costInterp, data.frame=T)
names(this.timeInterp) <- c("trainingExamples", "numPredictors", "seconds")
names(this.costInterp) <- c("trainingExamples", "numPredictors", "cost")

this.timeCostInterp <- this.timeInterp
this.timeCostInterp$cost <- this.costInterp$cost


## subset this accuracy surface to only 
this.timeCost.subset <- this.timeCostInterp[this.timeCostInterp$trainingExamples < threshold.numTex, ]
maxSubset <- this.timeCost.subset[this.timeCost.subset$trainingExamples == theMax$trainingExamples &
this.timeCost.subset$numPredictors == theMax$numPredictors, ]
maxSubset$grp <- value
scenarioOut[idx, ] <- maxSubset[c("grp", "cost", "seconds")]
idx = idx + 1

})
}
scenarioOut$cores <- sapply(strsplit(as.character(scenarioOut$grp), "\\."), "[", 1)
scenarioOut$GBMemory <- sapply(strsplit(as.character(scenarioOut$grp), "\\."), "[", 2)
```

```{r}
## this is different here, since we're working with interpolations
origin <- rep(0, length(scenarioOut))
pointSet <- scenarioOut[c("seconds", "cost")]
candidates <- rbind(pointSet, origin)
d <- as.matrix(dist(candidates))
fromOrigin <- d[,nrow(candidates)]
fromOrigin <- fromOrigin[fromOrigin > 0]
fromOrigin <- as.numeric(fromOrigin)
minDistIdx <- which.min(fromOrigin)
optimal <- scenarioOut[minDistIdx, ]

optimalDist <- min(fromOrigin)

xend = optimal$seconds
yend = optimal$cost

print(paste("Now there are only: ", nrow(scenarioOut), "candidates, instead of ", nrow(prices), "candidates that can complete this scenario under budget."))

## Plot the same thing, but now with the optimal marked
ggplot(scenarioOut) +
  geom_point(aes(x = cost, y = seconds)) +
  ggtitle("Random Forest Time/Cost Surface") +
  xlab("Cost (cents)") +
  ylab('Cost (seconds)')  +
  geom_segment(aes(x = 0, y=0, xend=cost, yend=seconds), alpha=0.075) +
  geom_point(data=optimal, aes(x = cost, y = seconds), col='red', size=3, shape=25)

print(paste("Recommended # cores: ", optimal$cores))
print(paste("Recommended Memory: ", optimal$GBMemory))
print(paste("Expected Cost: ", optimal$cost))
print(paste("Expected Seconds: ", optimal$seconds))
```



