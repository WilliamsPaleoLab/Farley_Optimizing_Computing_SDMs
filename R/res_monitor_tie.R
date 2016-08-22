library(zoo)
library(xts)





con <- dbConnect(dbDriver("MySQL"), host=hostname, username=username, dbname=dbname, password=password)
query <- "SELECT * FROM OtherResults2 where start > '2016-07-20 12:00:00';"
res <- dbGetQuery(con, query)
# names(res) <- c("ID", "taxon", "method", "location", "trainingExamples", "spatialResolution", "cores", "GBMemory", "totalTime",
#                 "fittingTime", "predictionTime", "accTime", "startTime", "computerID", "insertTime")

res$startTime <- as.POSIXct(res$start)
res$insertTime  <- as.POSIXct(res$insertTime)

resSplit <- split(res, as.factor(res$computerID))

instanceSmall <- resSplit[[1]]
instanceLarge <- resSplit[[2]]
willLab <- resSplit[[3]][1:50,]

plot(instanceSmall$totalTime ~ instanceSmall$trainingExamples, col='red')
points(instanceLarge$totalTime ~ instanceLarge$trainingExamples, col='blue')
points(willLab$totalTime ~ willLab$trainingExamples, col='purple')


rows <- rbind(instanceSmall, instanceLarge)
rows <- rbind(rows, willLab)



query <- "SELECT * FROM monitor where monitorTime > '2016-07-20 12:00:00' AND computerID = 'Williams-Lab' OR computerID= 'Instance-8-16' OR computerID = 'Instance-1-3.75';"
res <- dbGetQuery(con, query)
res$monitorTime  <- as.POSIXct(res$monitorTime)

compSplit <- split(res, as.factor(res$computerID))

instanceSmall.comp <- compSplit[[1]]
instanceLarge.comp <- compSplit[[2]]
willLab.comp <- compSplit[[3]]

willLab.comp$computerID <- NULL
willLab.comp <- data.frame(willLab.comp)
willLab.comp.monitorTime <- align.time(willLab.comp$monitorTime, 10)
willLab.comp.zoo <- read.zoo(willLab.comp,index="monitorTime")
willLab.CPU <- willLab.comp[c("CPU1", "CPU2", "CPU3", "CPU4", "CPU5", "CPU6", "CPU7", "CPU8", "CPUAverage", "runningProcesses", "monitorTime")]
willLab.mem <- willLab.comp[c("memoryUsed", "memoryPercent", "memoryAvailable", "runningProcesses", "monitorTime")]
willLab.other <- willLab.comp[c("CPUAverage", "CPUSwitches", "CPUInterrupts", "memoryUsed", "secondsSinceBoot", "monitorTime")]
willLab.summary <- willLab.comp[c("CPUAverage", "memoryPercent", "runningProcesses", "monitorTime")]
willLab.zoo.cpu <- read.zoo(willLab.CPU, index='monitorTime')
willLab.zoo.mem <- read.zoo(willLab.mem, index='monitorTime')
willLab.zoo.summary <- read.zoo(willLab.summary, index='monitorTime')
willLab.zoo.other <- read.zoo(willLab.other, index='monitorTime')


willLab.summary.smooth <- period.apply(willLab.zoo.summary, endpoints(willLab.zoo.summary, 'seconds', 30), mean)
plot(willLab.summary.smooth)

###############

instanceLarge.comp$computerID <- NULL
instanceLarge.comp <- data.frame(instanceLarge.comp)
instanceLarge.comp.monitorTime <- align.time(instanceLarge.comp$monitorTime, 10)
instanceLarge.comp.zoo <- read.zoo(instanceLarge.comp,index="monitorTime")
instanceLarge.CPU <- instanceLarge.comp[c("CPU1", "CPU2", "CPU3", "CPU4", "CPU5", "CPU6", "CPU7", "CPU8", "CPUAverage", "runningProcesses", "monitorTime")]
instanceLarge.mem <- instanceLarge.comp[c("memoryUsed", "memoryPercent", "memoryAvailable", "runningProcesses", "monitorTime")]
instanceLarge.other <- instanceLarge.comp[c("CPUAverage", "CPUSwitches", "CPUInterrupts", "memoryUsed", "secondsSinceBoot", "monitorTime")]
instanceLarge.summary <- instanceLarge.comp[c("CPUAverage", "memoryPercent", "runningProcesses", "monitorTime")]
instanceLarge.zoo.cpu <- read.zoo(instanceLarge.CPU, index='monitorTime')
instanceLarge.zoo.mem <- read.zoo(instanceLarge.mem, index='monitorTime')
instanceLarge.zoo.summary <- read.zoo(instanceLarge.summary, index='monitorTime')
instanceLarge.zoo.other <- read.zoo(instanceLarge.other, index='monitorTime')


instanceLarge.summary.smooth <- period.apply(instanceLarge.zoo.summary, endpoints(instanceLarge.zoo.summary, 'seconds', 30), mean)
plot(instanceLarge.summary.smooth)




instanceLarge.cpu.smooth <- period.apply(instanceLarge.zoo.cpu, endpoints(instanceLarge.zoo.cpu, 'seconds', 15), mean)
willLab.cpu.smooth <- period.apply(willLab.zoo.cpu, endpoints(willLab.zoo.cpu, 'seconds', 15), mean)

par(mfrow=c(2, 1))
plot(instanceLarge.zoo.cpu, plot.type='single', col=c("chartreuse","pink3","lightslategrey","gray46","sienna1","lemonchiffon1","gray36","gray62" ), xaxt='n')
plot(willLab.zoo.cpu, plot.type='single', col=c("chartreuse","pink3","lightslategrey","gray46","sienna1","lemonchiffon1","gray36","gray62" ))





###############
instanceSmall.comp$computerID <- NULL
instanceSmall.comp <- data.frame(instanceSmall.comp)
instanceSmall.comp.monitorTime <- align.time(instanceSmall.comp$monitorTime, 10)
instanceSmall.comp.zoo <- read.zoo(instanceSmall.comp,index="monitorTime")
instanceSmall.CPU <- instanceSmall.comp[c("CPU1", "CPU2", "CPU3", "CPU4", "CPU5", "CPU6", "CPU7", "CPU8", "CPUAverage", "runningProcesses", "monitorTime")]
instanceSmall.mem <- instanceSmall.comp[c("memoryUsed", "memoryPercent", "memoryAvailable", "runningProcesses", "monitorTime")]
instanceSmall.other <- instanceSmall.comp[c("CPUAverage", "CPUSwitches", "CPUInterrupts", "memoryUsed", "secondsSinceBoot", "monitorTime")]
instanceSmall.summary <- instanceSmall.comp[c("CPUAverage", "memoryPercent", "runningProcesses", "monitorTime")]
instanceSmall.zoo.cpu <- read.zoo(instanceSmall.CPU, index='monitorTime')
instanceSmall.zoo.mem <- read.zoo(instanceSmall.mem, index='monitorTime')
instanceSmall.zoo.summary <- read.zoo(instanceSmall.summary, index='monitorTime')
instanceSmall.zoo.other <- read.zoo(instanceSmall.other, index='monitorTime')


######
willLab <- data.frame(willLab)
willLab$taxon <- NULL
willLab$method <- NULL
willLab$computerID <- NULL
willLab.startTime <- align.time(as.POSIXct(willLab$startTime), 10)
willLab.events <- read.zoo(willLab, index='startTime')


willLab.merge <- merge(willLab.zoo.cpu, willLab.events)
z <- na.fill(willLab.merge, 0)
z <- period.apply(z, endpoints(z, 'seconds', 30), mean)

willLab.comp.xts <- as.xts(willLab.comp.zoo)

willLab$memory <- vector("numeric", length=nrow(willLab))
willLab$meanCPU <- vector("numeric", length=nrow(willLab))
willLab$maxCPU <- vector("numeric", length=nrow(willLab))
willLab$totalAverageCPU <- vector("numeric", length=nrow(willLab))
willLab$numMeasurements <- vector("numeric", length = nrow(willLab))
  
  
for (i in 1:nrow(willLab)){
  row = willLab[i,]
  startTime = row['startTime']
  endTime = row['insertTime']
  key = paste(startTime, "/", endTime, sep="")
  compRows <- willLab.comp.xts[key]
  if (nrow(compRows) > 0){
    meanMemory = mean(compRows$memoryPercent)
    meanCPU = mean(compRows$CPUAverage)
    maxCPU = max(compRows[,2:9])
    totalAverageCPU = mean(compRows[,2:9])
  }else{
    meanMemory <- NA
    meanCPU <- NA
    maxCPU <- NA
    totalAverageCPU <- NA
  }
  willLab$memory[i] <- meanMemory
  willLab$meanCPU[i]<- meanCPU
  willLab$maxCPU[i]<-maxCPU
  willLab$totalAverageCP[i] <- totalAverageCPU
  willLab$numMeasurements[i] <- nrow(compRows)
  print(i)
}



instanceLarge.comp.xts <- as.xts(instanceLarge.comp.zoo)

instanceLarge$memory <- vector("numeric", length=nrow(instanceLarge))
instanceLarge$meanCPU <- vector("numeric", length=nrow(instanceLarge))
instanceLarge$maxCPU <- vector("numeric", length=nrow(instanceLarge))
instanceLarge$totalAverageCPU <- vector("numeric", length=nrow(instanceLarge))
instanceLarge$numMeasurements <- vector("numeric", length = nrow(instanceLarge))


for (i in 1:nrow(instanceLarge)){
  row = instanceLarge[i,]
  startTime = format(row['startTime'], "%Y-%m-%d %H:%M:%S")
  print(startTime)
  endTime =  format(row['insertTime'], "%Y-%m-%d %H:%M:%S")
  key = paste(startTime, "/", endTime, sep="")
  print(key)
  compRows <- instanceLarge.comp.xts[key]
  if (nrow(compRows) > 0){
    meanMemory = mean(compRows$memoryPercent)
    meanCPU = mean(compRows$CPUAverage)
    maxCPU = max(compRows[,2:9])
    totalAverageCPU = mean(compRows[,2:9])
  }else{
    meanMemory <- NA
    meanCPU <- NA
    maxCPU <- NA
    totalAverageCPU <- NA
  }
  instanceLarge$memory[i] <- meanMemory
  instanceLarge$meanCPU[i]<- meanCPU
  instanceLarge$maxCPU[i]<-maxCPU
  instanceLarge$totalAverageCPU[i] <- totalAverageCPU
  instanceLarge$numMeasurements[i] <- nrow(compRows)
  print(i)
}




