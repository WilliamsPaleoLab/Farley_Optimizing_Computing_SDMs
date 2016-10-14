
con <- dbConnect(dbDriver("MySQL"), host=hostname, username=username, dbname=dbname, password=password)
query <- "SELECT * FROM monitor where monitorTime > '2016-07-20 12:00:00';"
res <- dbGetQuery(con, query)

res$computerID <- as.factor(res$computerID)
res$monitorTime <- as.POSIXct(res$monitorTime)

willLab <- res[which(res$computerID == "Williams-Lab"), ]
willLab$computerID <- NULL
willLab <- data.frame(willLab)
align.time(willLab$monitorTime, 10)
willLab.zoo <- read.zoo(willLab,index="monitorTime")
willLab.CPU <- willLab[c("CPU1", "CPU2", "CPU3", "CPU4", "CPU5", "CPU6", "CPU7", "CPU8", "CPUAverage", "runningProcesses", "monitorTime")]
willLab.mem <- willLab[c("memoryUsed", "memoryPercent", "memoryAvailable", "runningProcesses", "monitorTime")]
willLab.other <- willLab[c("CPUAverage", "CPUSwitches", "CPUInterrupts", "memoryUsed", "secondsSinceBoot", "monitorTime")]
willLab.summary <- willLab[c("CPUAverage", "memoryPercent", "runningProcesses", "monitorTime")]
willLab.zoo.cpu <- read.zoo(willLab.CPU, index='monitorTime')
willLab.zoo.mem <- read.zoo(willLab.mem, index='monitorTime')
willLab.zoo.summary <- read.zoo(willLab.summary, index='monitorTime')
willLab.zoo.other <- read.zoo(willLab.other, index='monitorTime')

willLab.summary.smooth <- period.apply(willLab.zoo.summary, endpoints(willLab.zoo.summary, "minutes", 1), mean)
willLab.CPU.smooth <- period.apply(willLab.zoo.cpu, endpoints(willLab.zoo.cpu, "minutes", 1), mean)
willLab.mem.smooth <- period.apply(willLab.zoo.mem, endpoints(willLab.zoo.mem, "minutes", 1), mean)
willLab.other.smooth <- period.apply(willLab.zoo.other, endpoints(willLab.zoo.other, "minutes", 1), mean)
plot(willLab.summary.smooth)
plot(willLab.CPU.smooth)


cg <- res[which(res$computerID == "Instance-1-3.75"), ]
cg$computerID <- NULL
cg <- data.frame(cg)
align.time(cg$monitorTime, 10)
cg.zoo <- read.zoo(cg,index="monitorTime")
cg.CPU <- cg[c("CPU1", "CPUAverage", "runningProcesses", "monitorTime")]
cg.mem <- cg[c("memoryUsed", "memoryPercent", "memoryAvailable", "runningProcesses", "monitorTime")]
cg.other <- cg[c("CPUAverage", "CPUSwitches", "CPUInterrupts", "memoryUsed", "secondsSinceBoot", "monitorTime")]
cg.summary <- cg[c("CPUAverage", "memoryPercent", "runningProcesses", "monitorTime")]
cg.zoo.cpu <- read.zoo(cg.CPU, index='monitorTime')
cg.zoo.mem <- read.zoo(cg.mem, index='monitorTime')
cg.zoo.summary <- read.zoo(cg.summary, index='monitorTime')
cg.zoo.other <- read.zoo(cg.other, index='monitorTime')

cg.summary.smooth <- period.apply(cg.zoo.summary, endpoints(cg.zoo.summary, "minutes", 1), mean)
cg.CPU.smooth <- period.apply(cg.zoo.cpu, endpoints(cg.zoo.cpu, "minutes", 1), mean)
cg.mem.smooth <- period.apply(cg.zoo.mem, endpoints(cg.zoo.mem, "minutes", 1), mean)
cg.other.smooth <- period.apply(cg.zoo.other, endpoints(cg.zoo.other, "minutes", 1), mean)
plot(cg.summary.smooth)
plot(cg.CPU.smooth)

db <- res[which(res$computerID == "SDM-Database"), ]
db$computerID <- NULL
db <- data.frame(db)
align.time(db$monitorTime, 10)
db.zoo <- read.zoo(db,index="monitorTime")
db.CPU <- db[c("CPU1", "CPUAverage", "runningProcesses", "monitorTime")]
db.mem <- db[c("memoryUsed", "memoryPercent", "memoryAvailable", "runningProcesses", "monitorTime")]
db.other <- db[c("CPUAverage", "CPUSwitches", "CPUInterrupts", "memoryUsed", "secondsSinceBoot", "monitorTime")]
db.summary <- db[c("CPUAverage", "memoryPercent", "memoryAvailable", "runningProcesses", "monitorTime")]
db.zoo.cpu <- read.zoo(db.CPU, index='monitorTime')
db.zoo.mem <- read.zoo(db.mem, index='monitorTime')
db.zoo.summary <- read.zoo(db.summary, index='monitorTime')
db.zoo.other <- read.zoo(db.other, index='monitorTime')

db.summary.smooth <- period.apply(db.zoo.summary, endpoints(db.zoo.summary, "minutes", 1), mean)
db.CPU.smooth <- period.apply(db.zoo.cpu, endpoints(db.zoo.cpu, "minutes", 1), mean)
db.mem.smooth <- period.apply(db.zoo.mem, endpoints(db.zoo.mem, "minutes", 1), mean)
db.other.smooth <- period.apply(db.zoo.other, endpoints(db.zoo.other, "minutes", 1), mean)
plot(db.summary.smooth)
plot(db.CPU.smooth)

willLab.summary.smooth < na.approx(willLab.summary.smooth)

otherRes <- dbGetQuery(con, "SELECT * FROM OtherResults2 where startUnix > '2016-07-20 12:00:00';")
names(otherRes) <- c("otherID", "taxon",  "method", "NA", "trainingExamples", "spatialResolution", "cores", "GBMemory", "totalTime", "fittingTime", "predictionTIme", "accTime",  "startUnix", "computerID", "insertTime")
otherRes$event <- 1
o <- otherRes[c("insertTime", "totalTime")]
o$monitorTime <- as.POSIXct(o$insertTime)
o <- o[c('monitorTime', "totalTime")]
o <- data.frame(o)
o.zoo <- read.zoo(o, index=1)

m <- merge(willLab.summary.smooth, o.zoo)
m <- merge(m, willLab.CPU.smooth)
#z <- na.fill(m, fill=0)
#z <- na.approx(m, na.rm=F)
z <- na.fill(m, fill=0)
z <- period.apply(z, endpoints(z, "seconds", 5), mean)
plot(z, type=c('l', 'l', 'l', 'l'), plot.type='single', col=c("red", "blue", "black", "green", 'purple'))
legend('right', c("CPU", "Memory", "Procs", "TotalTime"), fill=c("red", "blue", "black",  "purple"))


par(mfrow=c(3, 1))
plot(z[,1:3][-which(z[,1:3] == 0)], type=c('l', 'l', 'l'), plot.type='single', col=c("red", "blue", "black"), ylab='% Utilization',  xaxt='n')
plot(z[,6:13], type='l', plot.type='single', ylab='% Utilization Per CPU', col=sample(colours(), 5),  xaxt='n')
plot(z[,4][-which(z[,4] == 0)], type='p', col='purple', ylab='Elapsed Seconds',  pch=3)
#legend('bottomright', c("CPU", "Memory", "Procs", "Execution Time"), fill=c("red", "blue", "black", 'purple'))


