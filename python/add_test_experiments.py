__author__ = 'scottsfarley'
import mysql.connector
cnx = mysql.connector.connect(user='thesis-scripting', password='G0Bears7!',
                              host='107.180.50.243',
                              database='TimeSDM')

cursor = cnx.cursor()
coreOpts = [4, 8] ##cpu cores
memoryOpts = [-1] ## mbytes memory
srOpts = [0.1, 0.25, 0.5, 1] ##spatial resolution of predictors
nccOpts = [50, 500, 1000, 10000, 30000] ## number of training points
taxaOpts = ['betula', 'quercus', 'picea', 'tsuga']
repOpts = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

i = 0
expID = 0
for taxon in taxaOpts:
    for no in nccOpts:
        for sr in srOpts:
            for core in coreOpts:
                for mem in memoryOpts:
                    expID += 1
                    for rep in repOpts:
                        i += 1
                        # expString = str(expID) + "." + str(rep)
                        # data = (expID, expString, core, mem, sr, no, taxon, expID, rep)
                        # sql = "INSERT INTO Experiments VALUES (DEFAULT, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
                        # cursor.execute(sql, data)
print i

cnx.commit()
cursor.close()
cnx.close()