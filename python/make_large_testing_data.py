__author__ = 'scottsfarley'
import csv
import random
from random import choice
from string import ascii_uppercase
from string import digits
import sys

def createTestingData(totalSizeInBytes, f):
    header = ["SiteID", "SiteName", "Latitude", "Longitude", "Age", "pollenPercentage", "Bio2", "Bio7", "Bio8", "Bio15", "Bio18", "Bio19"]
    hndl = TrackedFile(f, 'w')
    writer = csv.writer(hndl)
    writer.writerow(header)
    h = []
    while hndl.size <= totalSizeInBytes:
        ##assemble each record separately

        ## 160 character site name as random string
        siteName = ''.join(choice(ascii_uppercase) for i in range(160))

        ## five digit random site code
        siteID = ''.join(choice(digits) for i in range(5))

        ## latitude and longitude are random double precisions with six decimal places
        lat = round(random.uniform(-90, 90), 6)
        lng = round(random.uniform(-180,180), 6)

        ## come up with some random ages between -50 and 22,000
        age = random.randint(-50, 22000)

        ## and random pollen percentages
        pct = random.random()

        ## and six double precision covariates

        ## first is bio2 [-150, 0]
        cov1 = random.uniform(-150, 0)

        ## bio 7 [-25, 25]
        cov2 = random.uniform(-25, 25)

        ## bio 8 [0, 50]
        cov3 = random.uniform(0, 50)

        ## bio 15 [0, 150[
        cov4 = random.uniform(0, 150)

        ## bio 18 [0, 25]
        cov5 = random.uniform(0, 25)

        ## bio 19 [-15, 35]
        cov6 = random.uniform(-15, 35)

        row = [siteID, siteName, lat, lng, age, pct, cov1, cov2, cov3, cov4, cov5, cov6]
        writer.writerow(row)
        h.append(hndl.delta)
        if (len(h)) % 10000 == 0:
            print "Current file size is:", hndl.size, "bytes"
    print "Wrote a file with", hndl.size, "bytes and ", len(h), "rows"
    print "Average row size is", sum(h)/len(h), "bytes"



class TrackedFile(file):
    def __init__(self, filename, mode):
        self.size = 0
        self.prevSize = 0
        self.delta = 0
        super(TrackedFile, self).__init__(filename, mode)
    def write(self, s):
        self.prevSize = self.size
        self.size += len(s)
        self.delta = self.size - self.prevSize
        super(TrackedFile, self).write(s)


createTestingData(1000, "/Volumes/PICEA/small_testData.csv")
