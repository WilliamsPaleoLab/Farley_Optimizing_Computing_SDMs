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


outBase = 'W:/Lab_Climate_Data/Working/Scott/CMIP5-HadGEM/2100/0_5_deg/'
ncid = netCDF4.Dataset("W:/Lab_Climate_Data/ModelData/cmip5/nc/rcp85_2/HadGEM2-ES/prcp.nc")
nc_dump.ncdump(ncid)


infile = "W:/Lab_Climate_Data/ModelData/cmip5/nc/rcp85_2/HadGEM2-ES/prcp.nc"
init_month = 1
init_year = 2006
var = 'prcp'
x_dimension = "lon"
y_dimension = "lat"
nc_FP = arcpy.NetCDFFileProperties(infile)
nc_Dim = nc_FP.getDimensions()
timeDim = nc_FP.getDimensionSize("time")

scale_factor = ncid.variables[var].getncattr('scale_factor')
add_offset = ncid.variables[var].getncattr('add_offset')


for month in range(1, 13):
    year = 2100
    outfile = var + "_" + str(month) + "_" + str(year)
    t = str(month) + '/1/2100'
    f = arcpy.MakeNetCDFRasterLayer_md(infile, var, x_dimension, y_dimension, outfile, "", [['time', t]], "BY_VALUE")
    f = f.getOutput(0)
    out2 = outfile + "2"
    out_raster = arcpy.MakeRasterLayer_management (f, out2)
    arcpy.Raster(out2)
    print out_raster
    out_raster = float(add_offset) + (Int(out2) * float(scale_factor))
    arcpy.CopyRaster_management(out_raster, outBase + outfile + ".tif", "", "", "", "NONE", "NONE", "")
    print outfile




#
# for dimension in nc_Dim:
#     if dimension == 'time':
#         for i in range(0, timeDim):
#             print nc_FP.getDimensionValue("time", i)

    # if dimension == "month":
    #     for i in range(0, 12):
    #         month = nc_FP.getDimensionValue(dimension, i)
    #         for y in range(0,timeDim):
    #             year = nc_FP.getDimensionValue("time", y)
    #             if year % 100 == 0:
    #                 ## 1000 year averages
    #                 outfile = var + "_" + str(month) + "_" + str(abs(year * 10))
    #                 f = arcpy.MakeNetCDFRasterLayer_md(infile, var, x_dimension, y_dimension, outfile, "", [["month", month], ["time", year]], "BY_VALUE")
    #                 f = f.getOutput(0)
    #                 out2 = outfile + "2"
    #                 out_raster = arcpy.MakeRasterLayer_management (f, out2)
    #                 arcpy.Raster(out2)
    #                 print out_raster
    #                 out_raster = float(add_offset) + (Int(out2) * float(scale_factor))
    #                 arcpy.CopyRaster_management(out_raster, outLoc + outfile + ".tif", "", "", "", "NONE", "NONE", "")
    #                 print outfile