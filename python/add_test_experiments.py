__author__ = 'scottsfarley'
import mysql.connector
cnx = mysql.connector.connect(user='thesis-scripting', password='G0Bears7!',
                              host='107.180.50.243',
                              database='TimeSDM')

cursor = cnx.cursor()
coreOpts = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24] ##cpu cores
memoryOpts = [-1, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24] ## mbytes memory --> -1 is inf
srOpts = [0.1, 0.25, 0.5, 1] ##spatial resolution of predictors
nccOpts = [50, 500, 1000, 10000, 30000] ## number of training points
taxaOpts = ['betula', 'quercus', 'picea', 'tsuga']
repOpts = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

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
                        expString = str(expID) + "." + str(rep)
                        data = (expID, expString, core, mem, sr, no, taxon, expID, rep)
                        sql = "INSERT INTO Experiments VALUES (DEFAULT, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'QUEUED', " \
                              "-1, DEFAULT)"
                        cursor.execute(sql, data)
                        if i % 100 == 0:
                            print i
print i
cnx.commit()
cursor.close()
cnx.close()