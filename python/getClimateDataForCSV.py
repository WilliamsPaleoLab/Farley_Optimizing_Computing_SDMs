import csv
import getFromNCFile
f = open("C://Users/willlab/documents/scott/thesis-scripts/data/occurrences/betula.csv", 'rU')
outf = open('C://Users/willlab/documents/scott/thesis-scripts/data/occurrences/betula_with_climate.csv', 'w')
reader = csv.reader(f)
writer = csv.writer(outf, lineterminator='\n')
oldHeader = ["SiteName", "Latitude", "Longitude", "ageYounger", "AgeOlder", "Age", "Taxon Name", "Value", "PollenSum", "Percentage", "Units", "Element", "Context", "Depth", "ColUnit"]
newHeader = ['siteName', 'latitude', 'longitude', 'age', 'pollenPercentage', 'pollenSum',
             'p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8', 'p9', 'p10', 'p11', 'p12',
             'tmin1', 'tmin2', 'tmin3', 'tmin4', 'tmin5', 'tmin6','tmin7', 'tmin8', 'tmin9', 'tmin10', 'tmin11', 'tmin12',
             'tmax1', 'tmax2', 'tmax3', 'tmax4', 'tmax5', 'tmax6', 'tmax7', 'tmax8', 'tmax9', 'tmax10', 'tmax11', 'tmax12']
writer.writerow(newHeader)
for row in reader:
    try:
        site = row[0]
        lat = float(row[1])
        lon = float(row[2])
        alt = float(row[3])
        age = row[7]
        ageOld = row[8]
        ageYoung = row[9]
        if age == '':
            try:
                age = (float(ageOld) + float(ageYoung)) / 2
            except Exception as e:
                age = 0 ##modern
        age = float(age)
        val = row[13]
        s = row[14]
        pct = row[12]
        out = [site, lat, lon, age, pct, s]
        print out
        #precip values
        p = getFromNCFile.getMonthlyValuesFromNCFile("W://Lab_Climate_Data/ModelData/TraCE/CCSM3/22k_monthly_avg/nc/ccsm3_22-0k_prcp.nc", 'prcp', age, lat, lon)
        p = list(p)
        out += p
        #temp
        tmin = getFromNCFile.getMonthlyValuesFromNCFile("W://Lab_Climate_Data/ModelData/TraCE/CCSM3/22k_monthly_avg/nc/ccsm3_22-0k_temp.nc", 'tmin', age, lat, lon)
        out += list(tmin)
        tmax = getFromNCFile.getMonthlyValuesFromNCFile("W://Lab_Climate_Data/ModelData/TraCE/CCSM3/22k_monthly_avg/nc/ccsm3_22-0k_temp.nc", 'tmax', age, lat, lon)
        out += list(tmax)
        writer.writerow(out)
    except Exception as e:
        print str(e)
        continue

outf.close()


