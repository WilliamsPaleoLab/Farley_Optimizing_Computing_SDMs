getSystemVars <- function(){
  out <- vector(mode='character')
  
  ## operating system variables come from base R function calls
  i <- Sys.info()
  out['osFamily'] <- i['sysname']
  out['osRelease'] <- i['release']
  out['osVersion'] <- i['version']
  out['nodeName'] <- i['nodename']
  out['machineArchitecture'] <- i['machine']
  ## use system calls to linux os to get system variables
  ## just produce console output, need to reformat into R vector
  ## lscpu command on linux provides cpu information
  cpuinfo <- system2("lscpu", stdout=TRUE)
  cpuinfo <- splitAndStrip(cpuinfo)
  ##number of CPUs
  out['numCPUs'] <- cpuinfo[[4]][2]
  out['threadsPerCPU'] <- cpuinfo[[6]][2]
  out['cpuVendor'] <- cpuinfo[[11]][2]
  out['cpuModelNumber'] <- cpuinfo[[12]][2]
  out['cpuModelName'] <- cpuinfo[[13]][2]
  out['cpuClockRate'] <- cpuinfo[[15]][2]
  out['cpuMIPS'] <- cpuinfo[[16]][2]
  out['Hypervisor'] <- cpuinfo[[17]][2]
  out['virtualization'] <- cpuinfo[[18]][2]
  out['L1d'] <- cpuinfo[[19]][2]
  out['L1i'] <- cpuinfo[[20]][2]
  out['L2'] <- cpuinfo[[21]][2]
  out['L3'] <- cpuinfo[[22]][2]
  ## /proc/meminfo on linux provides memory information
  memInfo <- system2("cat", "/proc/meminfo", stdout=TRUE)
  memInfo <- splitAndStrip(memInfo)
  out['totalMem'] <- memInfo[[1]][2]
  out['swapMem'] <- memInfo[[15]][2]
  ## returns the result as a named character vector
  return(out)
}

getRVars <- function(){
  out <- vector("character")
  rInfo <- R.Version()
  out['rPlatform'] <- rInfo$platform
  out['rVersion'] <- rInfo$version.string
  out['rnickname'] <- rInfo$nickname
  return(out)
}

splitAndStrip <- function(x, splitter=":", stripper=" "){
  p <- gsub(stripper, "", x, fixed = TRUE)
  o <- strsplit(p, splitter)
  return(o)
}

KBToGB <- function(x, strip=TRUE){
  if(strip){
    x <- gsub("kB", "", x, fixed=TRUE)
  }
  x <- (as.numeric(x)) / 1048576
  return(x)
}