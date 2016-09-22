install.packages(c("randomForest", "doMC", "foreach", "dismo", "raster", "gbm", "SDMTools", "RMySQL", "rgdal", "gam", "earth"), repos='http://cran.mtu.edu/')
source("/home/rstudio/thesis-scripts/R/time_sdm_generic.R")
library(earth)
library(gam)

ncores = detectCores()
nodename <- Sys.info()['nodename']
nodeSplit <- strsplit(nodename, "-")
globals.totalMemory = systemInfo[['totalMem']]
experimentMemory = nodeSplit[['nodename']][3]

taxon <- "Picea"
modelopts <- c("MARS", "GAM")
sr = c(0.1, 0.25, 0.5, 1)
reps = 5
noccOpts <- c(10000,20000, 30000, 40000, 50000)
taxonOpts <- c("Picea", "Betula", "Quercus", "Tsuga")
db=TRUE
stdout=TRUE

if(db){
  source("thesis-scripts/R/config.R")
  drv <- dbDriver("MySQL")
  con <- dbConnect(drv, host=hostname, username=username, password=password, dbname=dbname)
}

for (opt in modelopts){
  for (t in taxonOpts){
  
  for (sr in srOpts){
    for (n in noccOpts){
      for (rep in 1:reps){
        r <- timeSDM(taxon, ncores, experimentMemory, n, sr, modelMethod=opt)
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
    }
}
