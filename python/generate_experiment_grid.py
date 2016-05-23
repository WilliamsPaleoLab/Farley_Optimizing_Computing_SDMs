__author__ = 'scottsfarley'

import csv
import json



#writer = csv.writer(open('/Users/scottsfarley/documents/thesis-scripts/data/experiment_grid.csv','w'))

coreOpts = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24] ##cpu cores
memoryOpts = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24] ## mbytes memory
srOpts = [0.1, 0.25, 0.5, 1] ##spatial resolution of predictors
nccOpts = [50, 500, 1000, 10000, 30000] ## number of training points
taxaOpts = ['betula', 'quercus', 'picea', 'tsuga']
repOpts = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

header = ["ExperimentNumber", "ExperimentIdentifier", "Cores", "Memory", "SpatialResolution", "nTraining", "Taxon", "CellNumber", "ReplicateNumber"]
writer.writerow(header)


hier = {'name' : 'root', 'children' : []}

expID = 0
size = 1000
for c in coreOpts:
    cKey = "C" + str(c)
    cChildren = []
    for m in memoryOpts:
        mKey = "M" + str(m)
        mChildren = []
        for s in srOpts:
            sKey = 'S' + str(s)
            sChildren = []
            for no in nccOpts:
                noKey = "NO" + str(no)
                noChildren = []
                for t in taxaOpts:
                    expID += 1
                    tChildren = []
                    for rep in repOpts:
                        expIDString = str(expID) + "." + str(rep)
                        identifier = t + "_" + str(no) + "_" + str(s) + "_" + str(m) + "_" + str(c) + "." + str(rep)
                        experiment = [expIDString, identifier, c, m, s, no, t, expID, rep]
                        writer.writerow(experiment)
                        jsonOut = {'name' : expIDString, 'size' : size}
                        tChildren.append(jsonOut)
                        if expID % 1000 == 0:
                            print expIDString
                    tOut = {'name' : t, 'children': tChildren}
                    noChildren.append(tOut)
                noOut = {'name': noKey, 'children': noChildren}
                sChildren.append(noOut)
            sOut = {'name' :sKey, 'children' : sChildren}
            mChildren.append(sOut)
        mOut = {'name' : mKey, 'children' : mChildren}
        cChildren.append(mOut)
    cOut = {'name' : cKey, 'children' : cChildren}
    hier['children'].append(cOut)

json.dump(hier, open("/Users/scottsfarley/documents/thesis-scripts/web/treemap/hierarchy.json",'w'))








