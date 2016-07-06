library(jsonlite)

library(RMySQL)
getResults <- function(cellNumber = "", cores= "", memory = "", taxon = "", 
                       spatialResolution = "", trainingExamples = ""){
  drv <- dbDriver("MySQL")
  hostname="104.154.235.236"
  username <- "Scripting"
  password <- "Thesis-Scripting123!"
  dbname <- "timeSplot(r$DM"
  con <- dbConnect(drv, host=hostname, username=username, password=password, dbname=dbname)
  sql = "SELECT cores, GBMemory, trainingExamples, spatialResolution, totalTime, fittingTime, predictionTime, testingAUC, Results.cellID FROM Results INNER JOIN Experiments on Experiments.experimentID = Results.experimentID WHERE (1=1) "
  if (cellNumber != ""){
    sql = paste(sql, " AND Results.cellID=", cellNumber)
  }
  if(cores != ""){
    sql = paste(sql, " AND cores=", cores)
  }
  if(memory != ""){
    sql = paste(sql, " AND GBMemory=", memory)
  }
  if(taxon != ""){
    sql = paste(sql, " AND taxon=", taxon)
  }
  if(spatialResolution != ""){
    sql = paste(sql, " AND spatialResolution=", spatialResolution)
  }
  if (trainingExamples != ""){
    sql =paste(sql, " AND trainingExamples=", trainingExamples)
  }
  x <- dbGetQuery(con, sql)
  return(x)
}