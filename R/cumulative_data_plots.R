
## load libraries
library(devtools)
library(neotoma)
library(lubridate)
library(reshape2)
library(ggplot2)
library(ggthemes)
library(ggalt)

## get the dataset info from neotoma
neotoma_datasets <- get_dataset()

## parse the fields into indivudal objects
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

## plot total cumulative datasets
neotomaplot <- ggplot(totalCum, aes(x = date, y = value, group = type)) + 
  geom_line(aes(color = type)) +
  theme_bw() +
  xlab('Date') +
  ylab('Number of Datasets') +
  ggtitle("Neotoma Dataset Submissions") + theme(legend.position="none")
neotomaplot



# # ### PBDB
# counts <- vector()
# yearSeq <- seq(1996,2016)
# n <- length(yearSeq) - 1
# for (idx in 1:n){
#   try({
#     yr <- yearSeq[idx]
#     print(yr)
#     start <- paste(yr, "01", "01", sep='-')
#     end <- paste(yearSeq[idx+1], "12", "31", sep='-')
#     theseRecords <- pbdb_occurrences(limit='all', show=c('crmod', 'coords'), created_before=end, created_after=start)
#     write.csv(theseRecords, file=paste("/Users/scottsfarley/documents/thesis-scripts/data/PBDB_", yr, ".csv"))
#     counts[idx] <- nrow(theseRecords)
#     print(nrow(theseRecords))
#   })
# }
# 
# 
# save(pbdb_all, file="/users/scottsfarley/documents/thesis-scripts/data/pbdb_mods.RData")







# ##GBIF
# gbif_occs = occ_count(type='year')
# years = vector()
# counts <- vector()
# idx = 1
# for (i in names(gbif_occs)){
#  years[idx] = i
#  counts[idx] <- gbif_occs[[idx]]
#   idx = idx  + 1
# }
# 
# gbif_all <- data.frame(value=counts, year=years)
# 
# gbif_all$cumsum <- cumsum(gbif_all$value)
# gbif_all$year <- as.numeric(as.character(gbif_all$year))
# 
# ggplot(gbif_all, aes(x=year, y=cumsum)) + 
#   geom_line() 
#   xlab("Year") +
#   ylab("Number of Occurrences") +
#   ggtitle("GBIF Occurrences")

### Map geographic distribution of neotoma datasets through time
ND1995 <- list()
ND2000 <- list()
ND2005 <- list()
ND2010 <- list()
ND2016 <- list()
y <- vector()
for (idx in 1:length(neotoma_datasets)){
  thisDS <- neotoma_datasets[[idx]]
  thisSubDate <- as.Date(as.character(thisDS$submission$submission.date[[1]]))
  thisRoundDate <- round_date(thisSubDate, unit='year')
  thisYear <- year(thisRoundDate)
  thisYear <- as.numeric(thisYear)
  y[[idx]] <- thisYear
  if(length(thisYear) == 0){
    next
  }
  if(is.na(thisYear)){
    next
  }
  print(thisYear)
  if (thisYear <= 1995){
    print("Going to 1995")
    ND1995[[length(ND1995) + 1]] <- thisDS$site.data
  }
  else if (thisYear <= 2000){
    print("Going to 2000")
    ND2000[[length(ND2000) + 1]] <- thisDS$site.data
  }
  else if (thisYear <= 2005){
    print("Going to 2005")
    ND2005[[length(ND2005) + 1]] <- thisDS$site.data
  }
   else if (thisYear <= 2010){
     print("Going to 2010")
    ND2010[[length(ND2010) + 1]] <- thisDS$site.data
  }
  else if (thisYear <= 2016){
    print("Going to 2016")
    ND2016[[length(ND2016) + 1]] <- thisDS$site.data
  }
}


hist(y)
map("world", main="Neotoma Holdings, 1995")
lats <- vector()
lngs <- vector()
for (i in 1:length(ND1995)){
  d <- ND1995[[i]]
  lats[[length(lats) + 1]] <- d$lat
  lngs[[length(lngs) + 1]]  <- d$long
}
points(lngs, lats, col='darkblue', cex=0.25)

#map("world")
lats <- vector()
lngs <- vector()
for (i in 1:length(ND2000)){
  d <- ND2000[[i]]
  lats[[length(lats) + 1]] <- d$lat
  lngs[[length(lngs) + 1]]  <- d$long
}
points(lngs, lats, col='cyan', cex=0.25)
title("Neotoma Holdings, 2000")

#map("world")
lats <- vector()
lngs <- vector()
for (i in 1:length(ND2005)){
  d <- ND2005[[i]]
  lats[[length(lats) + 1]] <- d$lat
  lngs[[length(lngs) + 1]]  <- d$long
}
points(lngs, lats, col='magenta', cex=0.25)
title("Neotoma Holdings, 2005")

#map("world")
lats <- vector()
lngs <- vector()
for (i in 1:length(ND2010)){
  d <- ND2010[[i]]
  lats[[length(lats) + 1]] <- d$lat
  lngs[[length(lngs) + 1]]  <- d$long
}
points(lngs, lats, col='red', cex=0.25)
title("Neotoma Holdings, 2010")

# #map("world")
lats <- vector()
lngs <- vector()
for (i in 1:length(ND2016)){
  d <- ND2016[[i]]
  lats[[length(lats) + 1]] <- d$lat
  lngs[[length(lngs) + 1]]  <- d$long
}
points(lngs, lats, col='forestgreen', cex=0.25)
title("Neotoma Holdings, Today")



df <- data.frame(lat=vector('numeric', length(neotoma_datasets)), 
                 lng=vector('numeric',length(neotoma_datasets)), 
                 year=vector('numeric',length(neotoma_datasets)))
for (i in 1:length(neotoma_datasets)){
  lat <- neotoma_datasets[[i]]$site.data$lat
  lng <- neotoma_datasets[[i]]$site.data$long
  subDate <- neotoma_datasets[[i]]$submission$submission.date[[1]]
  subYear <- year(round_date(as.Date(as.character(subDate)), unit='year'))
  if (is.null(subYear)){
    subYear <- NA
  }
  v <- c(lat, lng, subYear)
  if (length(v) == 3){
    df[i,] <- v 
  }
  # print(i)
}

df$yearCat <- cut(as.numeric(df$year), breaks=c(1990, 1995, 2000, 2005, 2010, 2016))

world = map_data("world")
gg <- ggplot()
gg <- gg + geom_map(data=world, map=world,
                    aes(x=long, y=lat, map_id=region),
                    color="white", fill="#7f7f7f", size=0.1, alpha=2/4)
gg <- gg + geom_point(data=df, 
                      aes(x=lng, y=lat, color=yearCat), 
                      size=0.35, alpha=5/100)
gg <- gg + scale_color_tableau()
gg <- gg + coord_proj("+proj=wintri")
gg <- gg + facet_wrap(~yearCat)
gg <- gg + theme_map()
gg <- gg + theme(strip.background=element_blank())
gg <- gg + theme(legend.position="none")
gg <- gg + ggtitle("Spatiotemporal Distribution of Neotoma Holdings")
gg


df$type <- as.factor(df$type)
ggplot(df, aes(df$type)) + geom_bar() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle("Dataset Types in Neotoma") +
  xlab("") + ylab("Count")

# gbif_occ_types <- occ_count(type="basisOfRecord")
# gbif_occ_types <- melt(gbif_occ_types, data.frame)
# names(gbif_occ_types) <- c("numOfType", "Type")
# ggplot(gbif_occ_types, aes(x=Type, y=numOfType)) + 
#   geom_bar(stat="identity") +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
#   ggtitle("GBIF Record Types") +
#   xlab("") + ylab("Number of Records")



## Plot by principle investigator
neotoma_PIs <- melt(neotoma_PIs, data.frame)
neotoma_PIs <- table(neotoma_PIs)
neotoma_PIs <- as.data.frame(neotoma_PIs)

idx <- sort(neotoma_PIs$Freq, index.return=T, decreasing=T)$ix
neotoma_PIs <- neotoma_PIs[idx,]


ggplot(neotoma_PIs, aes( y=Freq, x=reorder(neotoma_PIs, Freq))) + 
  geom_bar(stat="Identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size=2)) +
  ggtitle("Neotoma Principle Investigator") +
  xlab("") + ylab("Number of Datasets Contributed")





