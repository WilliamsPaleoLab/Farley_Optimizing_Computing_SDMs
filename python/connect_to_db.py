import MySQLdb
print "Imported connector."

keys = open('/home/keys.txt', 'r')
pw = keys.readlines()[0].replace("\n", "")

dbParams = open('/host.txt', 'r')
host = dbParams.readlines()[0].replace("\n", "")

cnx = MySQLdb.connect(host='localhost', user='Scripting', db='timeSDM', passwd='Thesis-Scripting123!')
print "Connected."
cursor = cnx.cursor()

n = 10

## main experiment
configs = [(1, 1.0), (1, 2.0), (1, 3.0), (1, 4.0), (1, 6.0), (2, 2.0), (2, 3.0), (2, 4.0), (2, 6.0), (2, 9.0), (2, 12.0), (4, 4.0), (4, 6.0), (4, 9.0), (4, 12.0), (4, 15.0), (4, 18.0), (4, 21.0), (4, 24.0), (6, 6.0), (6, 9.0), (6, 12.0), (6, 15.0), (6, 18.0), (6, 21.0), (6, 24.0), (6, 27.0), (6, 30.0), (6, 33.0), (6, 36.0), (6, 39.0), (8, 9.0), (8, 12.0), (8, 15.0), (8, 18.0), (8, 21.0), (8, 24.0), (8, 27.0), (8, 30.0), (8, 33.0), (8, 36.0), (8, 39.0), (8, 42.0), (8, 45.0), (8, 48.0), (8, 51.0)]
trainingExamples = [10000, 20000, 30000]
spatialRes = [0.1, 0.25, 0.5, 1]
taxon = "Picea"
models = ['SVM', 'GAM', 'MARS']


catName = "Basic"
cell = 0
for comp in configs:
        for t in trainingExamples:
            for s in spatialRes:
                for model in models:
                    cell += 1
                    for i in range(n):
                        core = comp[0]
                        g = comp[1]
                        expName =  "Experiement: ", cell, "(", catName, "). Running", core, " cores with ",g, "GB memory. Taxon is ", taxon, " training on: ",t, " examples at SR: ", s, " replicate #",i
                        print expName
                        data = (cell, i, core, g, taxon, t, s, catName, model)
                        sql = "INSERT INTO Experiments VALUES(DEFAULT, -1, %s, %s, %s, %s, %s, %s, %s, NULL,%s, 'NOT STARTED', DEFAULT, DEFAULT, DEFAULT, %s);"
                        cursor.execute(sql, data)


# ##Super
# superConfs = [(16, 60), (32, 120), (32, 208)]
# catName = "Super"
# for conf in superConfs:
#     for t in trainingExamples:
#         for s in spatialRes:
#             cell += 1
#             for i in range(n):
#                 g = conf[1]
#                 core = conf[0]
#                 expName = 'NULL'#"Experiement: ", cell, "(", catName, "). Running", core, " cores with ",g, "GB memory. Taxon is ", taxon, " training on: ",t, " examples at SR: ", s, " replicate #",i
#                 print cell
#                 data = (cell, i, core, g, taxon, t, s, expName, catName)
#                 sql = "INSERT INTO Experiments VALUES(DEFAULT, -1, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'NOT STARTED', DEFAULT, DEFAULT, DEFAULT);"
#                 cursor.execute(sql, data)
#
# ## N sensitivity
# catName = "nSensitivity"
# trainingExamples = [100, 200, 300,400, 500, 600, 700,800, 900, 1000, 2000, 3000,
#                     4000, 5000, 6000, 7000, 8000, 9000, 10000, 15000, 20000, 25000, 30000]
# core = 4
# g = 16
# s = 0.25
# for t in trainingExamples:
#     cell += 1
#     for i in range(n):
#         expName = 'NULL'#"Experiement: ", cell, "(", catName, "). Running", core, " cores with ",g, "GB memory. Taxon is ", taxon, " training on: ",t, " examples at SR: ", s, " replicate #",i
#         data = (cell, i, core, g, taxon, t, s, expName, catName)
#         sql = "INSERT INTO Experiments VALUES(DEFAULT, -1, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'NOT STARTED',DEFAULT, DEFAULT, DEFAULT);"
#         cursor.execute(sql, data)
#
# ## sSensitivity
# catName = "sSensitivity"
# t = 1000
# core = 4
# g = 16
# spatialRes = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 2.5, 5]
# for s in spatialRes:
#     cell += 1
#     for i in range(n):
#         expName = 'NULL'#"Experiement: ", cell, "(", catName, "). Running", core, " cores with ",g, "GB memory. Taxon is ", taxon, " training on: ",t, " examples at SR: ", s, " replicate #",i
#         print cell
#         data = (cell, i, core, g, taxon, t, s, expName, catName)
#         sql = "INSERT INTO Experiments VALUES(DEFAULT, -1, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'NOT STARTED', DEFAULT, DEFAULT, DEFAULT);"
#         cursor.execute(sql, data)
#
# ## tSensitivity
# catName = "tSensitivity"
# taxa = ['Betula', "Picea", "Tsuga", "Quercus"]
# t = 1000
# s = 0.5
# confs = [(1, 3.75), (2, 7.5), (4, 15), (8, 30), (16, 60), (32, 120)]
# for c in confs:
#     for taxon in taxa:
#         cell += 1
#         for i in range(n):
#             core = c[0]
#             g = c[1]
#             expName = 'NULL' #"Experiement: ", cell, "(", catName, "). Running", core, " cores with ",g, "GB memory. Taxon is ", taxon, " training on: ",t, " examples at SR: ", s, " replicate #",i
#             print cell
#             data = (cell, i, core, g, taxon, t, s, expName, catName)
#             sql = "INSERT INTO Experiments VALUES(DEFAULT, -1, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'NOT STARTED', DEFAULT, DEFAULT, DEFAULT);"
#             cursor.execute(sql, data)
#
cnx.commit()
