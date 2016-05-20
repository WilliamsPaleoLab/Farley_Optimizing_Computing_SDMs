__author__ = 'scottsfarley'

import csv
import json

writer = csv.writer(open('/Users/scottsfarley/documents/thesis-scripts/data/experiment_grid.csv','w'))

coreOpts = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24] ##cpu cores
memoryOpts = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24] ## mbytes memory
srOpts = [0.1, 0.25, 0.5, 1] ##spatial resolution of predictors
nccOpts = [50, 500, 1000, 10000, 30000] ## number of training points
taxaOpts = ['betula', 'quercus', 'picea', 'tsuga']
repOpts = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

header = ["ExperimentNumber", "ExperimentIdentifier", "Cores", "Memory", "SpatialResolution", "nTraining", "Taxon", "CellNumber", "ReplicateNumber"]
writer.writerow(header)

expID = 0
for c in coreOpts:
    for m in memoryOpts:
        for s in srOpts:
            for no in nccOpts:
                for t in taxaOpts:
                    expID += 1
                    for rep in repOpts:
                        expIDString = str(expID) + "." + str(rep)
                        identifier = t + "_" + str(no) + "_" + str(s) + "_" + str(m) + "_" + str(c) + "." + str(rep)
                        experiment = [expIDString, identifier, c, m, s, no, t, expID, rep]
                        writer.writerow(experiment)
                        if expID % 1000 == 0:
                            print expIDString





