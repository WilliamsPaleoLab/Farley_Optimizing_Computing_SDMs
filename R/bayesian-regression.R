# library(RMySQL)
# library(R2jags)
# con <- dbConnect(dbDriver("MySQL"), host='104.154.235.236', password = 'Thesis-Scripting123!', dbname='timeSDM', username='Scripting')
# query <- "SELECT * FROM Results Inner Join Experiments on Experiments.experimentID = Results.experimentID;"
# res <- dbGetQuery(con, query)
# 
# calib.model.1 <- function(){
#   sigma ~ dunif(0, 10000)
#   sigma2Inv <- 1/(sigma*sigma)
#   beta1 ~ dnorm(0, 0.000001) ##cores
#   beta2 ~ dnorm(0,  0.000001) ##gbmemory
#   beta3 ~ dnorm(0,  0.000001) ##spatial res
#   beta4 ~ dnorm(0,  0.000001) ##training examples
#   epsilon ~ dnorm(0,  0.000001)
#   for (i in 1:nTrials){
#     # tObs[i] ~ dnorm(t[i], sigma2Inv)
#     t[i] ~ dnorm((beta1 * cores[i]) + (beta2 * memory[i]) + (beta3 * spatRes[i]) + (beta4 * trainingExamples[i]) + epsilon, sigma2Inv)
#   }
# }
# 
# cores <- res[['cores']]
# spatRes <- res[['spatialResolution']]
# trainingExamples <- res[['trainingExamples']]
# memory <- res[['GBMemory']]
# nTrials <- length(memory)
# t <- res[['totalTime']]
# 
# calib <- jags(data = list(cores=cores, spatRes=spatRes, 
#                         trainingExamples = trainingExamples, memory = memory, nTrials = nTrials,
#                         t=t),
#             parameters.to.save = c("beta1", "beta2", "beta3", "beta4", "sigma", "epsilon"),
#             n.chains = 1, n.iter = 2500, n.burnin=20, model.file = calib.model.1, DIC=FALSE)
# 
# out.mcmc  <- as.mcmc(calib)[[1]]
# 
# beta1.mean <- mean(out.mcmc[, "beta1"])
# beta2.mean <- mean(out.mcmc[, "beta2"])
# beta3.mean <- mean(out.mcmc[, "beta3"])
# beta4.mean <- mean(out.mcmc[, "beta4"])
# sigma.mean <- mean(out.mcmc[, "sigma"])
# epsilon.mean <- mean(out.mcmc[, "epsilon"])
# 
# beta1.var <- var(out.mcmc[, "beta1"])
# beta2.var <- var(out.mcmc[, "beta2"])
# beta3.var <- var(out.mcmc[, "beta3"])
# beta4.var <- var(out.mcmc[, "beta4"])
# sigma.var <- var(out.mcmc[, "sigma"])
# epsilon.var <- var(out.mcmc[, "epsilon"])
# 
# 
# con <- dbConnect(dbDriver("MySQL"), host='104.154.235.236', password = 'Thesis-Scripting123!', dbname='timeSDM', username='Scripting')
# ## get results from database
# r.brt <- dbGetQuery(con, "Select * From Experiments Inner Join Results on Results.experimentID = Experiments.experimentID
#                     WHERE experimentStatus = 'DONE' AND cores < 8 AND model = 'GBM-BRT';")
# 
# 
# r.brt.testingInd <- sample(nrow(r.brt), 100)
# r.brt.testing <- r.brt[r.brt.testingInd, ]
# 
# pred.model.1 <- function(){
#   #sigma ~ dnorm(sigma.mean, 1/sigma.var)
#   sigma2Inv <- 0.00001
#   beta1 ~ dnorm(beta1.mean, 1/beta1.var^2) ##cores
#   beta2 ~ dnorm(beta2.mean,  1/beta2.var^2) ##gbmemory
#   beta3 ~ dnorm(beta3.mean,  1/beta3.var^2) ##spatial res
#   beta4 ~ dnorm(beta4.mean,  1/beta4.var^2) ##training examples
#   epsilon ~ dnorm(epsilon.mean,  1/epsilon.var^2)
#   for (i in 1:nTrials){
#     # tObs[i] ~ dnorm(t[i], sigma2Inv)
#     t[i] ~ dlnorm((beta1 * cores[i]) + (beta2 * memory[i]) + (beta3 * spatRes[i]) + (beta4 * trainingExamples[i]) + epsilon, sigma2Inv)
#   }
# }
# 
# testing.cores <- r.brt.testing[['cores']]
# testing.spatRes <- r.brt.testing[['spatialResolution']]
# testing.memory <- r.brt.testing[['GBMemory']]
# testing.trainingExamples <- r.brt.testing[['trainingExamples']]
# nTrials <- length(testing.trainingExamples)
# 
# out <- jags(data = list(cores=testing.cores, spatRes=testing.spatRes, 
#                         trainingExamples = testing.trainingExamples, 
#                         memory = testing.memory, nTrials = nTrials, beta1.mean=beta1.mean, beta1.var=beta1.var, 
#                         beta2.mean=beta2.mean, beta2.var=beta2.var, beta3.mean=beta3.mean, beta3.var=beta3.var, 
#                         beta4.mean = beta4.mean, beta4.var=beta4.var, epsilon.mean=epsilon.mean, epsilon.var=epsilon.var,
#                         sigma.mean=sigma.mean, sigma.var=sigma.var),
#             parameters.to.save = c("t", "epsilon"),
#             n.chains = 1, n.iter = 3000, n.burnin=2000,  model.file = pred.model.1, DIC=FALSE)
# 
# #############################################################
# con <- dbConnect(dbDriver("MySQL"), host='104.154.235.236', password = 'Thesis-Scripting123!', dbname='timeSDM', username='Scripting')
# query <- "SELECT * FROM Results Inner Join Experiments on Experiments.experimentID = Results.experimentID;"
# res <- dbGetQuery(con, query)
# 
# 
# ## split the data into clusters
# t <- res[1:100, ]
# sorted.idx <- sort(as.numeric(t$cellID), index.return=TRUE)$ix
# t <- t[sorted.idx,]
# cells <- as.factor(t$cellID)
# splitter <- split(t, cells)
# coreData <- matrix(0, nrow = length(splitter), ncol=10)
# memData <- matrix(0,nrow = length(splitter), ncol=10)
# texData <- matrix(0,nrow = length(splitter), ncol=10)
# spData <- matrix(0,nrow = length(splitter), ncol=10)
# obsData <- matrix(0, nrow=length(splitter), ncol=10)
# for (i in 1:length(splitter)){
#   thisCluster <- splitter[[i]]
#   for (j in 1:nrow(thisCluster)){
#     print(j)
#     coreData[i, j] <- thisCluster$cores[[j]]
#     memData[i, j] <- thisCluster$GBMemory[[j]]
#     texData[i, j] <- thisCluster$trainingExamples[[j]]
#     spData[i, j] <- thisCluster$spatialResolution[[j]]
#     obsData[i, j] <- thisCluster$totalTime[[j]]
#   }
# }
# 
# nClusters <- nrow(obsData)
# nReps <- ncol(obsData)
# 
# modelstring <- "
# model{  
#   alpha ~ dnorm(0, 10000)
#   beta1 ~ dnorm(0, 10000)
#   beta2 ~ dnorm(0, 10000)
#   beta3 ~ dnorm(0, 10000)
#   beta4 ~ dnorm(0, 10000)
#   sigmaB ~ dunif(0, 10000)
#   sigmaY ~ dunif(0, 10000)
#   sigmaBInv <- 1/(sigmaB*sigmaB)
#   sigmaYInv <- 1/(sigmaY*sigmaY)
#   for (i in 1:nClusters){
#     b[i] ~ dnorm(0, sigmaBInv)
#     for (j in 1:nReps){
#       mu[i, j] <- alpha + (beta1 * cores[i, j]) 
#                         + (beta2 * memory[i, j]) 
#                         + (beta3 * sr[i, j]) 
#                         + (beta4 * tex[i, j])
#                         + b[i]
#       y[i, j] ~ dnorm(mu[i, j], sigmaYInv)
#     }
#   }
# }
# "
# writeLines(modelstring,con="calibration.txt")
# 
# ### Run the MCMC
# # calibration <- jags(data = list(cores=coreData, memory=memData, sr=spData, tex=texData, y=obsData, nClusters=nClusters, nReps=nReps),
# #             parameters.to.save = c("b", "sigmaY", "sigmaB", "beta1", "beta2", "beta3", "beta4", "alpha"),
# #             n.chains = 1, n.iter = 3000, n.burnin=2000,  model.file = model2, DIC=FALSE)
# # 
# 
# calibration = jags.model('calibration.txt', data = list(cores=coreData, memory=memData, sr=spData, tex=texData, y=obsData, nClusters=nClusters, nReps=nReps))
# library(coda)
# update(calibration, 1000)
# samp <- coda.samples(calibration, 
#                      variable.names=c("b", "sigmaY", "sigmaB", "beta1", "beta2", "beta3", "beta4", "alpha", "mu"), 
#                      n.iter=20000)
# 
# samps       <- samp[[1]]
# alpha.samps <- samps[, 1]
# b.samps    <- samps[,2:21] 
# beta1.samps <- samps[,22]
# beta2.samps <- samps[,23]
# beta3.samps <- samps[, 24]
# beta4.samps <- samps[, 25]
# muP.samps <- samps[, 26:225]
# sigmaY.samps  <- samps[,226]
# sigmaB.samps <- samps[,227]
# 
# b.mn <- colMeans(b.samps)
# alpha.mn <- mean(alpha.samps)
# beta1.mn <- mean(beta1.samps)
# beta2.mn <- mean(beta2.samps)
# beta3.mn <- mean(beta3.samps)
# beta4.mn <- mean(beta4.samps)
# sigmaY.mn <- mean(sigmaY.samps)
# betaB.mn <- mean(sigmaB.samps)
# muP.mn <- colMeans(muP.samps)
# 
# 
# idx <- 1
# for(i in 1:testing.nClusters){
#   plot(1, 1, main=paste("PPD for Cluster: ", i), xlim=c(-10, 500), xlab="Mu Posterior", ylim=c(0, 0.25))
#   # Plug-in
#   for (j in 1:testing.nReps){
#     lines(density(muP.samps[, idx]))
#     idx <- idx + 1
#     mu <- alpha.mn 
#        + (beta1.mn * testing.coreData[i, j]) 
#        + (beta2.mn*testing.memData[i, j])
#        + (beta3.mn*testing.spData[i, j]) 
#        + (beta4.mn*testing.texData[i, j])
#        + (b.mn[j])
#     y  <- rnorm(20000,mu,sigmaY.mn)
#     lines(density(y),col=2)
#     if (testing.obsData[i, j] != 0){
#       abline(v=(testing.obsData[i, j]),col=3,lwd=0.5)
#     }
#   }
#   # # Truth
#   # 
#   #legend("topright",c("PPD","Plug-in","Truth"),col=1:3,lty=1,inset=0.05)
# }
# 
# 
# 
# # 
# # ### Get parameter values and variances 
# # c1 <- as.mcmc(calibration)[[1]] ## first mcmc chain
# # alpha.mean <- mean(c1[, "alpha"])
# # alpha.var <- var(c1[, "alpha"])
# # beta1.mean <- mean(c1[,"beta1"])
# # beta1.var <- var(c1[, "beta1"])
# # beta2.mean <- mean(c1[, "beta2"])
# # beta2.var <- var(c1[, "beta2"])
# # beta3.mean <- mean(c1[, "beta3"])
# # beta3.var <- var(c1[, "beta3"])
# # beta4.mean <- mean(c1[, "beta4"])
# # beta4.var <- var(c1[, "beta4"])
# # sigmaY.mean <- mean(c1[, "sigmaY"])
# # sigmaY.var <- var(c1[, "sigmaY"])
# # sigmaB.mean <- mean(c1[, "sigmaB"])
# # sigmaB.var <- var(c1[, "sigmaB"])
# # 
# # s <- calibration$BUGSoutput$summary
# # s <- data.frame(s)
# # ## get the cluster deviation parameters
# # B.mean <- s$mean[2:21]
# # B.var <- s$sd[2:21]^2 ## variance instead of sd
# # 
# # #### Make Predictions
# # ## get the data
# # testing <- res[1:100, ][sample(100, 50),]
# # sorted.idx <- sort(as.numeric(t$cellID), index.return=TRUE)$ix
# # t <- t[sorted.idx,]
# # cells <- as.factor(t$cellID)
# # splitter <- split(t, cells)
# # testing.coreData <- matrix(0, nrow = length(splitter), ncol=10)
# # testing.memData <- matrix(0,nrow = length(splitter), ncol=10)
# # testing.texData <- matrix(0,nrow = length(splitter), ncol=10)
# # testing.spData <- matrix(0,nrow = length(splitter), ncol=10)
# # testing.obsData <- matrix(0, nrow=length(splitter), ncol=10)
# # for (i in 1:length(splitter)){
# #   thisCluster <- splitter[[i]]
# #   for (j in 1:nrow(thisCluster)){
# #     print(j)
# #     testing.coreData[i, j] <- thisCluster$cores[[j]]
# #     testing.memData[i, j] <- thisCluster$GBMemory[[j]]
# #     testing.texData[i, j] <- thisCluster$trainingExamples[[j]]
# #     testing.spData[i, j] <- thisCluster$spatialResolution[[j]]
# #     testing.obsData[i, j] <- thisCluster$totalTime[[j]]
# #   }
# # }
# # 
# # # 
# # # testing.nClusters <- nrow(obsData)
# # # testing.nReps <- ncol(obsData)
# # # 
# # # alpha.mean <- mean()
# # # 
# # # model2.predict <- function(){
# # #   alpha ~ dnorm(alpha.mean, 1/alpha.var)
# # #   beta1 ~ dnorm(beta1.mean, 1/beta1.var)
# # #   beta2 ~ dnorm(beta2.mean, 1/beta2.var)
# # #   beta3 ~ dnorm(beta3.mean, 1/beta3.var)
# # #   beta4 ~ dnorm(beta4.mean, 1/beta4.var)
# # #   sigmaBDraw ~ dnorm(sigmaB.mean, 1/(sigmaB.var^2))
# # #   sigmaYDraw ~ dnorm(sigmaY.mean, 1/(sigmaY.var^2))
# # #   sigmaB <- exp(sigmaBDraw)
# # #   sigmaY <- exp(sigmaYDraw)
# # #   sigmaBInv <- 1/(sigmaB*sigmaB)
# # #   sigmaYInv <- 1/(sigmaY*sigmaY)
# # #   for (i in 1:nClusters){
# # #     b[i] ~ dnorm(B.mean[i], 1/B.var[i])
# # #     for (j in 1:nReps){
# # #       mu[i, j] <- alpha + (beta1 * cores[i, j]) 
# # #       + (beta2 * memory[i, j]) 
# # #       + (beta3 * sr[i, j]) 
# # #       + (beta4 * tex[i, j])
# # #       + b[i]
# # #       y[i, j] ~ dnorm(mu[i, j], sigmaYInv)
# # #     }
# # #   }
# # # }
# # # 
# # # ### Run the MCMC
# # # prediction <- jags(data = list(alpha.mean = alpha.mean, alpha.var = alpha.var,
# # #                                beta1.mean = beta1.mean, beta1.var=beta1.var,
# # #                                beta2.mean=beta2.mean, beta2.var=beta2.var,
# # #                                beta3.mean=beta3.mean, beta3.var=beta3.var,
# # #                                beta4.mean=beta4.mean, beta4.var=beta4.var,
# # #                                sigmaY.mean = sigmaY.mean, sigmaY.var = sigmaY.var,
# # #                                sigmaB.mean = sigmaB.mean, sigmaB.var=sigmaB.var,
# # #                                B.mean = B.mean, B.var = B.var,
# # #                                
# # #                                cores = testing.coreData,
# # #                                memory=testing.memData, 
# # #                                sr=testing.spData, 
# # #                                tex=testing.texData, 
# # #                                nClusters=testing.nClusters, 
# # #                                nReps=testing.nReps),
# # #                     parameters.to.save = c("y"),
# # #                     n.chains = 1, n.iter = 3000, n.burnin=2000,  model.file = model2.predict, DIC=FALSE)
# # # 
# # # predictionChain <- as.mcmc(prediction)[[1]]
# # # predSum <- data.frame(prediction$BUGSoutput$summary)
# # # predSum.mean <- predSum$mean
# # # predSum.sd <- predSum$sd
# # # actual <- vector(length=length(predSum$mean))
# # # idx <- 1
# # # for (i in 1:testing.nClusters){
# # #   for (j in 1:testing.nReps){
# # #     actual[idx] <- testing.obsData[i, j]
# # #     idx <- idx + 1
# # #   }
# # # }
# # # 
# # # plot(predSum$mean, actual)


# Load the data

con <- dbConnect(dbDriver("MySQL"), host='104.154.235.236', password = 'Thesis-Scripting123!', dbname='timeSDM', username='Scripting')
query <- "SELECT * FROM Results Inner Join Experiments on Experiments.experimentID = Results.experimentID;"
dat <- dbGetQuery(con, query)
# dat <- dat[1:250,]

Y     <- dat[,6]
# Ymean <- mean(Y)
# Ysd <- sd(Y)
# Y     <- (Y-Ymean)/Ysd
X     <- dat[,c(35, 36, 38, 39)]
#X     <- X[,-10] # X1 and X10 are perfectly correlated
X     <- scale(X)

# Remove 5 observations for model fitting

test  <- c(20,40,60,80,100, 120, 140, 160, 180, 200, 220, 240)

Yo    <- Y[-test]    # Observed data
Xo    <- X[-test,]

Yp    <- Y[test]     # set aside for prediction
Xp    <- X[test,]

no    <- length(Yo)
np    <- length(Yp)
p     <- ncol(Xo)

library(rjags)


model_string <- "model{
  
  # Likelihood
  for(i in 1:no){
    Yo[i]   ~ dnorm(muo[i],inv.var)
    muo[i] <- alpha + inprod(Xo[i,],beta[])
  }
  
  # Prediction
    for(i in 1:np){
    Yp[i]  ~ dnorm(mup[i],inv.var)
    mup[i] <- alpha + inprod(Xp[i,],beta[])
  }
  
  # Priors
  for(j in 1:p){
    beta[j] ~ dnorm(0,0.0001)
  }
  alpha     ~ dnorm(0, 0.01)
  inv.var   ~ dgamma(0.01, 0.01)
  sigma     <- 1/sqrt(inv.var)
}"


model <- jags.model(textConnection(model_string), 
                    data = list(Yo=Yo,no=no,np=np,p=p,Xo=Xo,Xp=Xp))

update(model, 10000)

samp <- coda.samples(model, 
                     variable.names=c("beta","sigma","Yp","alpha"), 
                     n.iter=2000)

summary(samp)

#Extract the samples for each parameter

samps       <- samp[[1]]
Yp.samps    <- samps[,1:12] 
alpha.samps <- samps[,13]
beta.samps  <- samps[,14:17]
sigma.samps <- samps[,18]

# Compute the posterior mean for the plug-in predictions  

beta.mn  <- colMeans(beta.samps)
sigma.mn <- mean(sigma.samps)
alpha.mn <- mean(alpha.samps) 


# Plot the PPD and plug-in

for(j in 1:np){
  
  # PPD
  plot(density(Yp.samps[,j]),xlab="Y",main="PPD")
  
  # Plug-in
  mu <- alpha.mn+sum(Xp[j,]  *beta.mn)
  y  <- rnorm(20000,mu,sigma.mn)
  lines(density(y),col=2)
  
  # Truth
  abline(v=Yp[j],col=3,lwd=2)
  
  legend("topright",c("PPD","Plug-in","Truth"),col=1:3,lty=1,inset=0.05)
}

##de-scale
# Yp.samps.df <- data.frame(Yp.samps)
# Yp.samps.df <- (Yp.samps.df * Ysd) + Ymean
# Yp.toPlot <- as.matrix(Yp.samps.df)
plot(density(Yp.samps), ylim=c(0, 0.01), xlab='Execution Time', main="Postierior Densities and Truth")
for(j in 1:np){
  # PPD
  lines(density(Yp.toPlot[,j]), col='red', lwd=0.5)
  abline(v=(Yp[j]),col=3,lwd=0.25)
}
legend("topright",c("Plug-in","Truth"),col=2:3,lty=1,inset=0.05, bty = "n")



