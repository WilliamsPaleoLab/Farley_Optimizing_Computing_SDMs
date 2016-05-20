import matplotlib.pyplot as plt
def find_nearest(array,value):
    import numpy
    idx = numpy.argmin(numpy.abs(array - value))
    return array[idx]


def getSpaceTimeValueFromNCFile(ncfile, variable, yearBP, month, lat, lng):
    import netCDF4
    import numpy
    ncfile = netCDF4.Dataset(ncfile, 'r')
    #array the lats and lngs of the file
    lon_array = numpy.array(ncfile.variables['lon'])
    lat_array = numpy.array(ncfile.variables['lat'])
    time_array = numpy.array(ncfile.variables['time'])
    time_array = numpy.multiply(time_array, -10) #convert from decades to year bp

    # find the nearest point for latitude and longitude
    nearest_lat = find_nearest(lat_array, lat)
    nearest_lng = find_nearest(lon_array, lng)
    nearest_time = find_nearest(time_array, yearBP)
    print nearest_lat
    print nearest_lng
    print nearest_time
    # ## find the index at those points in the ncdf file
    lat_idx = numpy.where(lat_array == nearest_lat)[0][0]
    lon_idx = numpy.where(lon_array == nearest_lng)[0][0]
    time_idx = numpy.where(time_array == nearest_time)[0][0]
    # ## get the values at that lat, lng pair for all times
    v = ncfile.variables[variable][time_idx, month, lat_idx, lon_idx]
    return v

def getTimeSeriesFromNCFile(ncfile, variable, month, lat, lng):
    import netCDF4
    import numpy
    ncfile = netCDF4.Dataset(ncfile, 'r')
    #array the lats and lngs of the file
    lon_array = numpy.array(ncfile.variables['lon'])
    lat_array = numpy.array(ncfile.variables['lat'])

    # find the nearest point for latitude and longitude
    nearest_lat = find_nearest(lat_array, lat)
    nearest_lng = find_nearest(lon_array, lng)
    print nearest_lat
    print nearest_lng
    # ## find the index at those points in the ncdf file
    lat_idx = numpy.where(lat_array == nearest_lat)[0][0]
    lon_idx = numpy.where(lon_array == nearest_lng)[0][0]
    # ## get the values at that lat, lng pair for all times
    v = ncfile.variables[variable][:, month, lat_idx, lon_idx]
    return v

def getLatTransectFromNCFile(ncfile, variable, yearBP, month, lng):
    import netCDF4
    import numpy
    ncfile = netCDF4.Dataset(ncfile, 'r')
    #array the lats and lngs of the file
    lon_array = numpy.array(ncfile.variables['lon'])

    time_array = numpy.array(ncfile.variables['time'])
    time_array = numpy.multiply(time_array, -10) #convert from decades to year bp

    # find the nearest point for latitude and longitude
    nearest_lng = find_nearest(lon_array, lng)
    nearest_time = find_nearest(time_array, yearBP)
    print nearest_lng
    print nearest_time
    # ## find the index at those points in the ncdf file
    lon_idx = numpy.where(lon_array == nearest_lng)[0][0]
    time_idx = numpy.where(time_array == nearest_time)[0][0]
    # ## get the values at that lat, lng pair for all times
    v = ncfile.variables[variable][time_idx, month, :, lon_idx]
    return v

def getLonTransectFromNCFile(ncfile, variable, yearBP, month, lat):
    import netCDF4
    import numpy
    ncfile = netCDF4.Dataset(ncfile, 'r')
    #array the lats and lngs of the file
    lon_array = numpy.array(ncfile.variables['lat'])

    time_array = numpy.array(ncfile.variables['time'])
    time_array = numpy.multiply(time_array, -10) #convert from decades to year bp

    # find the nearest point for latitude and longitude
    nearest_lat = find_nearest(lon_array, lat)
    nearest_time = find_nearest(time_array, yearBP)
    print nearest_lat
    print nearest_time
    # ## find the index at those points in the ncdf file
    lat_idx = numpy.where(lon_array == nearest_lat)[0][0]
    time_idx = numpy.where(time_array == nearest_time)[0][0]
    # ## get the values at that lat, lng pair for all times
    v = ncfile.variables[variable][time_idx, month, lat_idx, :]
    return v

def getMonthlyValuesFromNCFile(ncfile, variable, yearBP, lat, lng):
    import netCDF4
    import numpy
    ncfile = netCDF4.Dataset(ncfile, 'r')
    #array the lats and lngs of the file
    lon_array = numpy.array(ncfile.variables['lon'])
    lat_array = numpy.array(ncfile.variables['lat'])
    time_array = numpy.array(ncfile.variables['time'])
    time_array = numpy.multiply(time_array, -10) #convert from decades to year bp

    # find the nearest point for latitude and longitude
    nearest_lat = find_nearest(lat_array, lat)
    nearest_lng = find_nearest(lon_array, lng)
    nearest_time = find_nearest(time_array, yearBP)
    # ## find the index at those points in the ncdf file
    lat_idx = numpy.where(lat_array == nearest_lat)[0][0]
    lon_idx = numpy.where(lon_array == nearest_lng)[0][0]
    time_idx = numpy.where(time_array == nearest_time)[0][0]
    # ## get the values at that lat, lng pair for all times
    v = ncfile.variables[variable][time_idx, :, lat_idx, lon_idx]
    return v

def getFullTimeSeriesFromNCFile(ncfile, variable, lat, lng):
    import netCDF4
    import numpy
    ncfile = netCDF4.Dataset(ncfile, 'r')
    #array the lats and lngs of the file
    lon_array = numpy.array(ncfile.variables['lon'])
    lat_array = numpy.array(ncfile.variables['lat'])
    time_array = numpy.array(ncfile.variables['time'])
    time_array = numpy.multiply(time_array, -10) #convert from decades to year bp

    # find the nearest point for latitude and longitude
    nearest_lat = find_nearest(lat_array, lat)
    nearest_lng = find_nearest(lon_array, lng)
    print nearest_lat
    print nearest_lng
    # ## find the index at those points in the ncdf file
    lat_idx = numpy.where(lat_array == nearest_lat)[0][0]
    lon_idx = numpy.where(lon_array == nearest_lng)[0][0]
    # ## get the values at that lat, lng pair for all times
    t = []
    for year in time_array:
        time_idx = numpy.where(time_array == year)[0][0]
        for month in range(0, 12):
            v = ncfile.variables[variable][time_idx, month, lat_idx, lon_idx]
            t.append(v)
    return t

