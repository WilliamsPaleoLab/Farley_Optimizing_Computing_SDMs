library(RMySQL)
library(R2jags)
con <- dbConnect(dbDriver("MySQL"), host=hostname, username=username, dbname=dbname, password=password)
query <- "SELECT * FROM Results Inner Join Experiments on Experiments.experimentID = Results.experimentID;"
res <- dbGetQuery(con, query)

model <- function(){
  sigma ~ dunif(0, 10000)
  sigma2Inv <- 1/(sigma*sigma)
  beta1 ~ dnorm(0, 0.000001) ##cores
  beta2 ~ dnorm(0,  0.000001) ##gbmemory
  beta3 ~ dnorm(0,  0.000001) ##spatial res
  beta4 ~ dnorm(0,  0.000001) ##training examples
  epsilon ~ dnorm(0,  0.000001)
  for (i in 1:nTrials){
    # tObs[i] ~ dnorm(t[i], sigma2Inv)
    t[i] ~ dnorm((beta1 * cores[i]) + (beta2 * memory[i]) + (beta3 * spatRes[i]) + (beta4 * trainingExamples[i]) + epsilon, sigma2Inv)
  }
}

cores <- res[['cores']]
spatRes <- res[['spatialResolution']]
trainingExamples <- res[['trainingExamples']]
memory <- res[['GBMemory']]
nTrials <- length(memory)
t <- res[['totalTime']]

out <- jags(data = list(cores=cores, spatRes=spatRes, 
                        trainingExamples = trainingExamples, memory = memory, nTrials = nTrials,
                        t=t),
            parameters.to.save = c("beta1", "beta2", "beta3", "beta4", "sigma", "epsilon"),
            n.chains = 1, n.iter = 20000, n.burnin=1, model.file = model, DIC=FALSE)