## plot the total number of occurrences ***(Sum of Rows x Columns of each datasets)***  in Neotoma
library(neotoma)

## Get the datasets via the api
datasets <- get_dataset()


## parse the fields into a data frame which is 
res <- data.frame(dsID=vector('numeric', length=length(datasets)), 
                  siteName=vector('numeric', length(datasets)), 
                  levels=vector('numeric', length(datasets)),
                  taxa=vector('numeric', length(datasets)),
                  occurrences = vector('numeric', length(datasets)),
                  dsType = vector('numeric', length(datasets)),
                  date = vector('character', length(datasets)))


## For each dataset, get the donwload and evaluate total occurrences 

for (i in 1:length(datasets)){
  thisDS <- datasets[[i]]
  ## get the download object 
  tryCatch({
    d <- get_download(thisDS)
    ## get the count data 
    counts <- d[[1]]$counts
    ## for each
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
    print((i/length(datasets))*100)
    # print(subm)
    v <- c(dsid, siteName, nlevels, ntaxa, nocc, dsType, subm)
    # print(v)
    res[i, ] <- v
  }, error= function(){ print("errored")})
}

write.csv(res, file="/users/scottsfarley/documents/neotoma_all.csv")