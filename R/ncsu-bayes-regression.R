# Load the data

dat   <- read.csv("http://www4.stat.ncsu.edu/~reich/ST590/assignments/Obama2012.csv")
Y     <- dat[,2]
Y     <- (Y-mean(Y))/sd(Y)
X     <- dat[,4:18]
X     <- X[,-10] # X1 and X10 are perfectly correlated
X     <- scale(X)

# Remove 5 observations for model fitting

test  <- c(20,40,60,80,100)

Yo    <- Y[-test]    # Observed data
Xo    <- X[-test,]

Yp    <- Y[test]     # Counties set aside for prediction
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

update(model, 10000, progress.bar="none")

samp <- coda.samples(model, 
                     variable.names=c("beta","sigma","Yp","alpha"), 
                     n.iter=20000, progress.bar="none")

summary(samp)

#Extract the samples for each parameter

samps       <- samp[[1]]
Yp.samps    <- samps[,1:5] 
alpha.samps <- samps[,6]
beta.samps  <- samps[,7:20]
sigma.samps <- samps[,21]

# Compute the posterior mean for the plug-in predictions  

beta.mn  <- colMeans(beta.samps)
sigma.mn <- mean(sigma.samps)
alpha.mn <- mean(alpha.samps) 


# Plot the PPD and plug-in

for(j in 1:np){
  
  # PPD
  plot(density(Yp.samps[,j]),xlab="Y",main="PPD")
  
  # Plug-in
  mu <- alpha.mn+sum(Xp[j,]*beta.mn)
  y  <- rnorm(20000,mu,sigma.mn)
  lines(density(y),col=2)
  
  # Truth
  abline(v=Yp[j],col=3,lwd=2)
  
  legend("topright",c("PPD","Plug-in","Truth"),col=1:3,lty=1,inset=0.05)
}