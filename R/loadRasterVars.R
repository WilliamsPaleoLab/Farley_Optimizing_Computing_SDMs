library(raster)
loadRasterStack <- function(basepath, var, ext = "tif", year='0'){
  pat = paste("_", year, "." , ext, sep="")
  files = list.files(basepath, pattern=pat);
  toStack <- vector(length = 12, mode='character');
  i = 1
  j = 1
  while (i < length(files)){
    f = files[i]
    prefix = substring(f, 0, 4)
    suffix = substrRight(f, 3)
    if ((suffix == ext) && (prefix == var)){
      fname = paste(basepath, f, sep="")
      toStack[j] =fname
      j = j + 1
    }
    i= i + 1
  }
  s = stack(toStack)
  return(s)
}

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

tmax2100 = loadRasterStack("W:/Lab_Climate_Data/ModelData/TraCE/CCSM3/22k_monthly_avg/1000_year_avg/", 'tmax')
tmin2100 = loadRasterStack("W:/Lab_Climate_Data/ModelData/TraCE/CCSM3/22k_monthly_avg/1000_year_avg/", 'tmin')
prcp2100 = loadRasterStack("W:/Lab_Climate_Data/ModelData/TraCE/CCSM3/22k_monthly_avg/1000_year_avg/", 'prcp')
bv2100 = biovars(prcp2100, tmin2100, tmax2100)