source("C://users/willlab/documents/scott/thesis-scripts/R/time_sdm_generic.R")

taxon <- "Picea"
ncores <- 8
memory <- 16
modelopts <- c("GBM-BRT", "MARS", "GAM")
sr = 0.5
reps = 10
noccOpts <- c(100, 500, 1000, 2000, 5000)
db=TRUE
stdout=TRUE
compID = "Williams-Lab"

if(db){
  source("thesis-scripts/R/config.R")
  drv <- dbDriver("MySQL")
  con <- dbConnect(drv, host=hostname, username=username, password=password, dbname=dbname)
}

for (opt in modelopts){
  for (n in noccOpts){
    for (rep in 1:reps){
      r <- timeSDM(taxon, ncores, memory, n, sr, modelMethod=opt)
      if (stdout){
        print(paste("Running: ", opt, n, "#", rep))
      }
      if (db){
        sql = paste("INSERT INTO OtherResults VALUES(default, '", r['Species'], "','", r['ModelMethod'], "','NA',", r['trainingexamples'], ",", r['spatialResolution'], ",",
                    r['cores'], ",", r['memory'], ",", r['totalTime'], ",", r['fitTime'], ",", r['predTime'], ",", r['accTime'], ",", r['startTime'], ",'", compID, "',default);", sep="")
        dbSendQuery(con, sql)
      }
      if(stdout){
        print(r)
      }
    }
  }
}
