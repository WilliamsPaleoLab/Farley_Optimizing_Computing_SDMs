__author__ = 'scottsfarley'
import csv

def threshold_csv(infile, outfile, fieldName, threshold):
    try:
        data = []
        reader = csv.DictReader(open(infile, 'r'))
        keys = reader.fieldnames
        keys.append("presence")
        for row in reader:
            val = float(row[fieldName])
            if val >= threshold:
                val = 1
            else:
                val = 0
            row['presence'] = val
            data.append(row)
        writer = csv.DictWriter(open(outfile, 'w'), fieldnames=keys, lineterminator='\n')
        writer.writeheader()
        writer.writerows(data)
        return True
    except Exception as e:
        print str(e)
        return False

threshold_csv("/users/scottsfarley/documents/thesis-scripts/data/sequoia_bioclim.csv", "/users/scottsfarley/documents/thesis-scripts/data/sequoia_bioclim_threshold.csv", 'pollenPercentage', 1)
