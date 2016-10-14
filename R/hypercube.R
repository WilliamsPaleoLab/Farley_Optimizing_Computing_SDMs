
learningRateOpts <- seq(0.001, 0.11, by=0.5)
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

# timeAndCost <- data.frame(
#   learningRate = vector('numeric', length=n),
#   treeComplexity = vector('numeric', length=n),
#   trainingExamples = vector('numeric', length=n),
#   numPredictors = vector('numeric', length=n),
#   cells = vector('numeric', length=n),
#   cores = vector('numeric', length=n),
#   GBMemory = vector('numeric', length=n),
#   seconds = vector('numeric', length=n),
#   cost = vector('numeric', length=n),
#   accuracy = vector('numeric', length = n))

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

# print(paste("N is ", n))
# pb <- txtProgressBar(min=0, max=n, )
# idx <- 1
# for (lr in learningRateOpts){
#   for (tc in treeComplexityOpts){
#     for(ntex in nTexOpts){
#       for (cell in cellOpts){
#         for(np in nPOpts){
#           for (cID in 1:nrow(prices)){
#             thisComp <- prices[cID,]
#             thisComp.cores <- thisComp$CPUs
#             thisComp.memory <- thisComp$GBsMem
#             scenario <- c(cores = thisComp.cores, 
#                           GBMemory = thisComp.memory, 
#                           trainingExamples=ntex, 
#                           numPredictors = np,
#                           cells=cell,
#                           learningRate = lr,
#                           treeComplexity = tc
#             )
#             v <- c(lr, tc, ntex, np, cell, thisComp.cores, thisComp.memory, 0, 0, 0)
#             if (is.null(v)){
#               v <- c(rep(0, 10))
#             }
#             timeAndCost[[idx]] <- v
#             setTxtProgressBar(pb, idx)
#             idx = idx + 1
#           }
#         }
#       }
#     }
#   }
# }

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




