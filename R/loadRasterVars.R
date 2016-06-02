library(raster)
library(dismo)
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

####################0.5 degree resolution ############################
tmax2100.05deg = loadRasterStack("W:/Lab_Climate_Data/Working/Scott/CMIP5-HadGEM/2100/0_5_deg/", 'tmax', year=2100)
tmin2100.05deg = loadRasterStack("W:/Lab_Climate_Data/Working/Scott/CMIP5-HadGEM/2100/0_5_deg/", 'tmin', year=2100)
prcp2100.05deg = loadRasterStack("W:/Lab_Climate_Data/Working/Scott/CMIP5-HadGEM/2100/0_5_deg/", 'prcp', year=2100)
bv2100.05deg = biovars(prcp2100.05deg, tmin2100.05deg, tmax2100.05deg)
bv2100.05deg <- stack(c(bv2100.05deg[[2]],bv2100.05deg[[7]], bv2100.05deg[[8]], bv2100.05deg[[15]], bv2100.05deg[[18]], bv2100.05deg[[19]]))
writeRaster(bv2100.05deg, "C:/Users/willlab/Documents/Scott/thesis-scripts/data/predictors/standard_biovars/0_5_deg/standard_biovars_0_5_deg_2100.tif")


####################0.25 degree resolution ############################
tmax2100.025deg = loadRasterStack("W:/Lab_Climate_Data/Working/Scott/CMIP5-HadGEM/2100/0_25_deg/", 'tmax', year=2100)
tmin2100.025deg = loadRasterStack("W:/Lab_Climate_Data/Working/Scott/CMIP5-HadGEM/2100/0_25_deg/", 'tmin', year=2100)
prcp2100.025deg = loadRasterStack("W:/Lab_Climate_Data/Working/Scott/CMIP5-HadGEM/2100/0_25_deg/", 'prcp', year=2100)
bv2100.025deg = biovars(prcp2100.025deg, tmin2100.025deg, tmax2100.025deg)
bv2100.025deg <- stack(c(bv2100.025deg[[2]],bv2100.025deg[[7]], bv2100.025deg[[8]], bv2100.025deg[[15]], bv2100.025deg[[18]], bv2100.025deg[[19]]))
writeRaster(bv2100.025deg, "C:/Users/willlab/Documents/Scott/thesis-scripts/data/predictors/standard_biovars/0_25_deg/standard_biovars_0_25_deg_2100.tif")

####################0.1 degree resolution ############################
tmax2100.01deg = loadRasterStack("W:/Lab_Climate_Data/Working/Scott/CMIP5-HadGEM/2100/0_1_deg/", 'tmax', year=2100)
tmin2100.01deg = loadRasterStack("W:/Lab_Climate_Data/Working/Scott/CMIP5-HadGEM/2100/0_1_deg/", 'tmin', year=2100)
prcp2100.01deg = loadRasterStack("W:/Lab_Climate_Data/Working/Scott/CMIP5-HadGEM/2100/0_1_deg/", 'prcp', year=2100)
bv2100.01deg = biovars(prcp2100.01deg, tmin2100.01deg, tmax2100.01deg)
bv2100.01deg <- stack(c(bv2100.01deg[[2]],bv2100.01deg[[7]], bv2100.01deg[[8]], bv2100.01deg[[15]], bv2100.01deg[[18]], bv2100.01deg[[19]]))
writeRaster(bv2100.01deg, "C:/Users/willlab/Documents/Scott/thesis-scripts/data/predictors/standard_biovars/0_1_deg/standard_biovars_0_1_deg_2100.tif")

####################1 degree resolution ############################
tmax2100.1deg = loadRasterStack("W:/Lab_Climate_Data/Working/Scott/CMIP5-HadGEM/2100/1_deg/", 'tmax', year=2100)
tmin2100.1deg = loadRasterStack("W:/Lab_Climate_Data/Working/Scott/CMIP5-HadGEM/2100/1_deg/", 'tmin', year=2100)
prcp2100.1deg = loadRasterStack("W:/Lab_Climate_Data/Working/Scott/CMIP5-HadGEM/2100/1_deg/", 'prcp', year=2100)
bv2100.1deg = biovars(prcp2100.1deg, tmin2100.1deg, tmax2100.1deg)
bv2100.1deg <- stack(c(bv2100.1deg[[2]],bv2100.1deg[[7]], bv2100.1deg[[8]], bv2100.1deg[[15]], bv2100.1deg[[18]], bv2100.1deg[[19]]))
writeRaster(bv2100.1deg, "C:/Users/willlab/Documents/Scott/thesis-scripts/data/predictors/standard_biovars/1_deg/standard_biovars_1_deg_2100.tif")
