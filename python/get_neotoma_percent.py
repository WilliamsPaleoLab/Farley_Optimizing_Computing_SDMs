## Gets relative abundances from Neotoma Paleoecological Database for a given taxa-string
import csv
import requests
import json
import sys
import pprint

outputFile = "/Users/scottsfarley/documents/thesis-scripts/data/occurrences/Quercus.csv"



output = {
    'collectionUnitHandle' : None,
    'collectionUnitID' : None,
    'collectionUnitType' : None,
    'datasetType' : None,
    'datasetName' : None,
    'datasetID' : None,
    'siteName' : None,
    'siteLatitude' : None,
    'siteLongitude' : None,
    'siteAltitude' : None,
    'siteID' : None,
    'chronologyID' : None,
    'chronologyType' : None,
    'ageOld' : None,
    'ageYoung' : None,
    'age' : None,
    'depth' : None,
    'thickness' : None,
    'pollenSum' : None,
    'taxonSum' : None,
    'taxonPercent' : None,
    'countedInLevel' : None,
    'totalInLevel' : None
}

outputkeys= ['siteName', 'siteLatitude', 'siteLongitude', 'siteAltitude', 'siteID', 'depth', 'thickness', 'age', 'ageOld', 'ageYoung',
             'chronologyType', 'chronologyID', 'taxonPercent',
             'taxonSum', 'pollenSum', 'countedInLevel', 'totalInLevel',
             'datasetID', 'datasetType', 'collectionUnitType', 'collectionUnitHandle', 'collectionUnitID']
#  outputkeys = output.keys()

writer = csv.DictWriter(open(outputFile, 'w'), fieldnames=outputkeys)
writer.writeheader()

taxonSearch = "Quercus*"


testString = ''.join(ch for ch in taxonSearch if ch.isalnum()) ## this is the searchstring without anything else
testString = testString.upper()


searchEndpoint = "http://api.neotomadb.org/v1/data/datasets?"
bbox = '-167.2764,5.4995,-52.23204,83.162102' ## North America
searchString = searchEndpoint + 'taxonname=' + taxonSearch + "&loc=" + bbox

datasets = requests.get(searchString).json()
if datasets['success']:
    numDatasets = len(datasets['data'])
    print "Found ", numDatasets, "datasets for", taxonSearch
else:
    ## API didn't return successfully.
    print "API Server returned an error.  Cannot continue..."
    sys.exit(1)

downloadEndpoint = "http://api.neotomadb.org/v1/data/downloads/"
datasets = datasets['data'] ## just keep the data part

it = 0
for dataset in datasets:
    ## these are dataset dictionaries as documented in neotoma api
    ## iterate over all of them and get the properties.  Then download the raw data
    colUnitName = dataset['CollUnitName']
    colUnitType = dataset['CollUnitType']
    colUnitHandle = dataset['CollUnitHandle']
    colUnitID = dataset['CollectionUnitID']
    datasetID = dataset['DatasetID']
    datasetName = dataset['DatasetName']
    datasetType = dataset['DatasetType']
    siteName = dataset['Site']['SiteName']
    siteLat = (float(dataset['Site']['LatitudeNorth']) + float(dataset['Site']['LatitudeSouth']))/2
    siteLng = (float(dataset['Site']['LongitudeEast']) + float(dataset['Site']['LongitudeWest']))/2
    siteAlt = dataset['Site']['Altitude']
    siteID = dataset['Site']['SiteID']
    siteDesc = dataset['Site']['SiteDescription']
    downloadString = downloadEndpoint + str(datasetID)
    print "Downloading dataset #", datasetID
    download = requests.get(downloadString).json()
    if download['success']:
        pass
    else:
        print "API Server returned an error.  Passing this dataset...."
        continue ## this dataset will not be returned in the final file
    download = download['data'][0] ## just keep the first item in the data array
    chronID = download['DefChronologyID'] ## default chronology ID
    samples = download['Samples'] ## this is an array
    ## iterate through all of the samples (these are levels in a core)
    for sample in samples:
        depth = sample['AnalysisUnitDepth']
        thickness = sample['AnalysisUnitThickness']
        name = sample['AnalysisUnitName']
        ## get sample ages
        ## if there are multiple --> idk what to do
        ## so just use the default
        ages = sample['SampleAges']
        ## set default sample ages
        age = -9999
        ageOld = -9999
        ageYoung = -9999
        ageType = None
        for sampleage in ages:
            thisChronID = sampleage['ChronologyID']
            if thisChronID == chronID: ## only use this age if it is the dataset's default chronology
                age = sampleage['Age']
                ageType = sampleage['AgeType']
                ageOld = sampleage['AgeOlder']
                ageYoung = sampleage['AgeYounger']
        ## now get the sample data
        sampledata = sample['SampleData']
        taxonValue = 0
        levelTotal = 0
        countedInLevel = 0
        totalInLevel = 0
        for sd in sampledata: ## these are the actual counts
            taxon = sd['TaxonName'].upper()
            value = sd['Value']
            element = sd['VariableElement']
            if element == 'pollen':
                levelTotal += value
                countedInLevel += 1
            if testString in taxon:
                taxonValue += value
            totalInLevel += 1
        ## format the output
        try:
            output = {
                'collectionUnitHandle' : colUnitHandle,
                'collectionUnitID' : colUnitID,
                'collectionUnitType' : colUnitType,
                'datasetType' : datasetType,
                'datasetID' : datasetID,
                'siteName' : siteName.encode("utf-8", "replace"),
                'siteLatitude' : siteLat,
                'siteLongitude' : siteLng,
                'siteAltitude' : siteAlt,
                'siteID' : siteID,
                'chronologyID' : chronID,
                'chronologyType' : ageType,
                'ageOld' : ageOld,
                'ageYoung' : ageYoung,
                'age' : age,
                'depth' : depth,
                'thickness' : thickness,
                'pollenSum' : levelTotal,
                'taxonSum' : taxonValue,
                'taxonPercent' : (taxonValue / levelTotal) * 100,
                'countedInLevel' : countedInLevel,
                'totalInLevel': totalInLevel
            }
            writer.writerow(output)
        except Exception as e:
            pass
    print (it / numDatasets)*100
















