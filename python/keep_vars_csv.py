__author__ = 'scottsfarley'
import csv
def keep_csv(infile, outfile, fieldnames):
    try:
        data = []
        reader = csv.DictReader(open(infile, 'r'))
        keys = fieldnames
        for row in reader:
            newRow = []
            for field in fieldnames:
                newRow.append(row[field])
            data.append(newRow)
        writer = csv.writer(open(outfile, 'w'),lineterminator='\n')
        writer.writerow(keys)
        writer.writerows(data)
        return True
    except Exception as e:
        print str(e)
        return False

keep_csv("/users/scottsfarley/documents/thesis-scripts/data/sequoia_bioclim_threshold.csv", "/users/scottsfarley/documents/thesis-scripts/data/sequoia_ready.csv",
              ['siteName', 'latitude', 'longitude', 'age', 'pollenPercentage', 'presence', 'bio2', 'bio7', 'bio8', 'bio15',
              'bio18', 'bio19'])


