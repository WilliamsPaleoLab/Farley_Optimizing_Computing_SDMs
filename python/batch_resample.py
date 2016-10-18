import netCDF4
import nc_dump
from arcpy.sa import *
import arcpy




import arcpy
from arcpy.sa import *

if arcpy.CheckExtension("Spatial") == "Available":
    arcpy.CheckOutExtension("Spatial")
else:
    arcpy.AddError("Unable to get spatial analyst extension")
    arcpy.AddMessage(arcpy.GetMessages(0))
    sys.exit(0)

inpath = "W:/Lab_Climate_Data/Working/Scott/CMIP5-HadGEM/2100/0_5_deg/"
outpath = "W:/Lab_Climate_Data/Working/Scott/CMIP5-HadGEM/2100/1_deg/"
arcpy.env.workspace = inpath
rasters = arcpy.ListRasters()
for raster in rasters:
    outfile = outpath + raster
    arcpy.Resample_management(inpath + raster, outfile, 1, 'CUBIC')
    print "Completed: " + raster