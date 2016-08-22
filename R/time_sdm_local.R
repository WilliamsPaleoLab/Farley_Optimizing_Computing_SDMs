source("/home/rstudio/thesis-scripts/R/time_sdm_generic.R")
library(earth)
library(gam)


taxon <- "Picea"
ncores <- 8
memory <- 16
modelopts <- c("MARS", "GAM", 'GBM-BRT')
sr = 0.5
reps = 10
noccOpts <- c(10000,20000, 30000, 40000, 50000)
db=TRUE
stdout=TRUE
compID = "Instance-8-16"

if(db){
  source("thesis-scripts/R/config.R")
  drv <- dbDriver("MySQL")
  con <- dbConnect(drv, host=hostname, username=username, password=password, dbname=dbname)
}

for (opt in modelopts){
  for (n in noccOpts){
    for (rep in 1:reps){
      r <- timeSDM(taxon, ncores, memory, n, sr, modelMethod=opt)
      print(r)
      if (stdout){
        print(paste("Running: ", opt, n, "#", rep))
      }
      if (db){
        sql = paste("INSERT INTO OtherResults2 VALUES(default, '", r['Species'], "','", r['ModelMethod'], "','NorthAmerica',", r['trainingexamples'], ",", r['spatialResolution'], ",", r['cores'] , ",", r['memory'], ",", r['totalTime'], ",", r['fitTime'], ",", r['predTime'], ",", r['accTime'], ",", r['AUC'] ,  ",'", r['startTime'], "','", compID, "',default);", sep="")
        dbSendQuery(con, sql)
      }
      if(stdout){
        print(r)
      }
    }
  }
}
