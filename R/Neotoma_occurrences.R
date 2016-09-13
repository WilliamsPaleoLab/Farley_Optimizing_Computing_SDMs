library(neotoma)

datasets <- get_dataset()

res <- data.frame(dsID=vector('numeric', length=length(datasets)), 
                  siteName=vector('numeric', length(datasets)), 
                  levels=vector('numeric', length(datasets)),
                  taxa=vector('numeric', length(datasets)),
                  occurrences = vector('numeric', length(datasets)),
                  dsType = vector('numeric', length(datasets)),
                  date = vector('character', length(datasets)))

for (i in 1:length(datasets)){
  thisDS <- datasets[[i]]
  d <- get_download(thisDS)
  counts <- d[[1]]$counts
  nlevels <- nrow(counts)
  ntaxa <- length(counts)
  nocc <- ntaxa * nlevels
  dsid <- d[[1]]$dataset$dataset.meta$dataset.id
  siteName <- d[[1]]$dataset$site.data$site.name
  dsType <- d[[1]]$dataset$dataset.meta$dataset.type
  subm <- thisDS$submission$submission.date[[1]]
  print(subm)
  if (is.null(subm)){
    subm <- NA
  }
  if (is.null(dsid)){
    dsid <- NA
  }
  if(is.null(siteName)){
    siteName <- NA
  }
  if(is.null(nlevels)){
    nlevels <- NA
  }
  if (is.null(ntaxa)){
    ntaxa <- NA
  }
  if(is.null(nocc)){
    nocc <- NA
  }
  if(is.null(dsType)){
    dsType <- NA
  }
  if(is.null(subm)){
    subm <- subm <- NA
  }
  print(subm)
  v <- c(dsid, siteName, nlevels, ntaxa, nocc, dsType, subm)
  print(v)
  res[i, ] <- v
}