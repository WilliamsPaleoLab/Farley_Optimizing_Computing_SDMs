def extractAllNetCDF(netcdf_file, var):
    import arcpy
    print "imported modules."
    variable = var
    x_dimension = "lon"
    y_dimension = "lat"
    band_dimension = ""
    dimension = "time"
    valueSelectionMethod = "BY_VALUE"

    outLoc = "W:/Lab_Climate_Data/ModelData/TraCE/CCSM3/22k_monthly_avg/decadal_raster/"
    inNetCDF = netcdf_file

    nc_FP = arcpy.NetCDFFileProperties(inNetCDF)
    print nc_FP
    nc_Dim = nc_FP.getDimensions()
    print nc_Dim

    for dimension in nc_Dim:
        if dimension == "time":
            top = nc_FP.getDimensionSize(dimension)
            for i in range(0, top):
                dimension_values = nc_FP.getDimensionValue(dimension, i)

                scaleFactor = nc_FP.getDI
                print "Time is ", dimension_values
                if dimension_values % 100 == 0:

                    nowFile = str(dimension_values)
                    nowFile = nowFile.translate(None, '/')
                    print nowFile

                    dv1 = ["time", dimension_values]
                    dimension_values = [dv1]

                    arcpy.MakeNetCDFRasterLayer_md(inNetCDF, variable, x_dimension, y_dimension, nowFile, band_dimension, dimension_values, valueSelectionMethod)
                    print "success"
                    outname = outLoc + nowFile

                    arcpy.CopyRaster_management(nowFile, outname, "", "", "", "NONE", "NONE", "")


#
# extractAllNetCDF("W:/Lab_Climate_Data/ModelData\TraCE/CCSM3/22k_monthly_avg/nc/ccsm3_22-0k_prcp.nc", "prcp")

import nc_dump
import netCDF4
# f = "W:/Lab_Climate_Data/ModelData\TraCE/CCSM3/22k_monthly_avg/nc/ccsm3_22-0k_prcp.nc"
# d = netCDF4.Dataset(f)
# nc_dump.ncdump(d)



import arcpy
from arcpy.sa import *

if arcpy.CheckExtension("Spatial") == "Available":
    arcpy.CheckOutExtension("Spatial")
else:
    arcpy.AddError("Unable to get spatial analyst extension")
    arcpy.AddMessage(arcpy.GetMessages(0))
    sys.exit(0)


infile = "W:/Lab_Climate_Data/ModelData\TraCE/CCSM3/22k_monthly_avg/nc/ccsm3_22-0k_temp.nc"
outLoc = "W:/Lab_Climate_Data/ModelData/TraCE/CCSM3/22k_monthly_avg/1000_year_avg/"
var = 'tmin'
x_dimension = "lon"
y_dimension = "lat"
nc_FP = arcpy.NetCDFFileProperties(infile)
nc_Dim = nc_FP.getDimensions()
timeDim = nc_FP.getDimensionSize("time")
monthDim = 12

ncid = netCDF4.Dataset(infile)
vars = ncid.variables

scale_factor = ncid.variables[var].getncattr('scale_factor')
add_offset = ncid.variables[var].getncattr('add_offset')



for dimension in nc_Dim:
    if dimension == "month":
        for i in range(0, 12):
            month = nc_FP.getDimensionValue(dimension, i)
            for y in range(0,timeDim):
                year = nc_FP.getDimensionValue("time", y)
                if year % 100 == 0:
                    ## 1000 year averages
                    outfile = var + "_" + str(month) + "_" + str(abs(year * 10))
                    f = arcpy.MakeNetCDFRasterLayer_md(infile, var, x_dimension, y_dimension, outfile, "", [["month", month], ["time", year]], "BY_VALUE")
                    f = f.getOutput(0)
                    out2 = outfile + "2"
                    out_raster = arcpy.MakeRasterLayer_management (f, out2)
                    arcpy.Raster(out2)
                    print out_raster
                    out_raster = float(add_offset) + (Int(out2) * float(scale_factor))
                    arcpy.CopyRaster_management(out_raster, outLoc + outfile + ".tif", "", "", "", "NONE", "NONE", "")
                    print outfile
#
