library(corrplot)
library(usdm)

## Get the raw correlation matrix between the layer stack
jnk=layerStats(bv, 'pearson', na.rm=T)
corr_matrix=jnk$'pearson correlation coefficient'

corrplot(corr_matrix, type = 'upper') ##plot the correlation matrix



## get the variance inflation factor between the layer stack

vifstep(bv, th=Inf, maxobservations=1000000000)
