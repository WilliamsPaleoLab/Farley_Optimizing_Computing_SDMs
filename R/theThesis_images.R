library(akima)
prices <- read.csv("/users/scottsfarley/documents/thesis-scripts/data/costs2.csv")
# prices <- prices[-which(prices$TotalRate > 10),]


## Computing Costs
## interp to linear grid
par(mar=mar.default)
i <- interp(prices$CPUs,prices$GBsMem,prices$TotalRate, xo=c(1:22), yo=c(1:22))
filled.contour(i, xlab='CPU', ylab='Memory (GB)', main="Computing Hourly Rate", 
               col=rev(heat.colors(n=30, alpha=0.7)))


p## Neotoma and GBIF Figure

library(devtools)
library(rgbif)
library(earthlife)
library(neotoma)
library(paleobioDB)
library(lubridate)
library(reshape2)
library(ggplot2)


neotoma_datasets <- get_dataset()


neotoma_sub_dates = vector()
neotoma_sub_names = vector()
neotoma_sub_types = vector()
neotoma_site_names = vector()
neotoma_PIs <- vector()
for (idx in 1:length(neotoma_datasets)){
  thisDS = neotoma_datasets[[idx]]
  subdates = thisDS$submission$submission.date
  if(!is.null(subdates)){
    ##first submission date
    thisDate = subdates[[1]]
    neotoma_sub_dates[idx] = as.character(thisDate)
    thisName = thisDS$dataset.meta$collection.handle
    thisType = thisDS$dataset.meta$dataset.type
    neotoma_sub_names[idx] = thisName
    neotoma_sub_types[idx] = thisType
    neotoma_site_names[idx] = thisDS$site.data$site.name
    PIList <- thisDS$pi.data$ContactName
    for (i in 1:length(PIList)){
      thisPI <- as.character(PIList[i])
      if (length(thisPI > 0)){
        neotoma_PIs[idx] <- thisPI
        print(thisPI)
      }
    }
  }
}


##PLOT NUMBER OF DATASETS 
## convert from character to dates and round to the nearest month
df = data.frame(subDate=neotoma_sub_dates, name=neotoma_sub_names, type=neotoma_sub_types, siteNames = neotoma_site_names)
df$subDate <- as.character(df$subDate)
df$subDate <- as.Date(df$subDate)
df$subDate <- round_date(df$subDate, unit='month')

## aggregate by type and date
caster <- dcast(df, formula = type ~ subDate, fun.aggregate=length)

## aggregate over all types
caster[, 1] <- as.character(caster[,1]) ## covert the type names to character (I think they were factor before)
caster$type[nrow(caster)] <- "Neotoma" # bottom row (all records)
caster[nrow(caster),2:ncol(caster)] <- colSums(caster[1:(nrow(caster)-1),2:ncol(caster)]) ## aggregate over all dates, but ignore the first column, which has type names in it


## apply the cumulative sum over all rows and all columns using some nifty indexing
tc <- caster
tc[, 7] <- rowSums(tc[, 2:7])
tc[nrow(tc), 8] <- tc[nrow(tc), 7] + tc[nrow(tc), 8]
tc[,8:ncol(tc)] <- t(apply(tc[,8:ncol(tc)], 1, cumsum))

## get ready to plot
toPlot <- melt(tc[,c(1, 8:ncol(tc))]) ## only aggregate on the rows that contain dates --> gets tricky because we went from rows to columns and back 
toPlot$date <- as.Date(as.character(toPlot$variable))

totalCum <- toPlot[which(toPlot$type == "Neotoma"),]


neotomaplot <- ggplot(totalCum, aes(x = date, y = value, group = type)) + 
  geom_line(aes(color = type)) +
  theme_bw() +
  xlab('Date') +
  ylab('Number of Datasets') +
  ggtitle("Neotoma Dataset Submissions") + theme(legend.position="none")
neotomaplot

### GBIF Plot

gbif_all <- data.frame(value=counts, year=years)

gbif_all$cumsum <- cumsum(gbif_all$value)
gbif_all$year <- as.numeric(as.character(gbif_all$year))

ggplot(gbif_all, aes(x=year, y=cumsum)) + 
  geom_line() + geom_rug(aes(x=NULL)) +
  xlab("Year") +
  ylab("Number of Occurrences") +
  ggtitle("GBIF Occurrences")


## plot the nuber of articles per year
articles <- read.csv("/users/scottsfarley/documents/thesis-scripts/data/SDM_Trends.csv")
names(articles) <- c("Year", "Articles", "Pct", "Growth")
articles <- articles[-1,] ## rm header
articles$Year <- as.numeric(as.character(articles$Year))
articles$Articles <- as.numeric(as.character(articles$Articles))
articles$Pct <- as.numeric(as.character(articles$Pct))
articles$Growth <- as.numeric(as.character(articles$Growth))
nsf_totalRate <- 2.8
a <- articles[which(articles$Year > 1995),]
a <- a[which(a$Year < 2015),]

z <- vector('numeric', length=18)
z[1] <- 752
for (y in 2:19){
  z[y] <- z[y-1] * 1.07
}

a$NSF <- rev(z)



ggplot(a) + 
  geom_line(aes(x=Year, y=Articles, col='SDM Citation Growth')) + 
  geom_point(aes(x=Year, y=Articles)) +
  geom_line(aes(x=Year, y=NSF, col='Average Citation Growth')) +
  ylab("Number of SDM Citations") +
  ggtitle("Web of Science Citations") +
  theme(legend.position="right", legend.title=element_blank()) +
  scale_colour_manual(values=c("SDM Citation Growth" = 'blue', "Average Citation Growth" = 'black'))

### Meta Analysis
meta <- read.csv("/Users/scottsfarley/documents/thesis-scripts/data/meta_analysis.csv")
mar.default <- c(5,3,3,2) + 0.1
par(oma=c(0,0,2,0))
par(mfrow=c(1, 2), mar = mar.default + c(0, 7, 0, 0))
plot(as.factor(meta$NameFixed),las=2, horiz=T, xlab="Instances", cex.lab=1, 
     cex.names=0.67)
par(mar=mar.default)
l <- c("NA", "Model-Driven", "Data-Driven", "Bayesian")
f <- factor(as.character(meta$Tier), labels=l)
plot(f, horiz=T, xlab="Instances")
title("Algorithms Used in SDM Literature", outer=T)





