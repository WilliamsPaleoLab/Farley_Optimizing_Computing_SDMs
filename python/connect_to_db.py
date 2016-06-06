import MySQLdb
print "Imported connector."

keys = open('/keys.txt', 'r')
pw = keys.readlines()[0]

dbParams = open('/host.txt', 'r')
host = dbParams.readlines()[0]

cnx = MySQLdb.connect(unix_socket=host, user='root', db='timeSDM', passwd=pw)
print "Connected."
cursor = cnx.cursor()

n = 10

## main experiment
cores = [1, 2, 3, 4, 5, 6, 7, 8, 10, 16, 20, 24]
gb = [1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 16, 20, 24]
trainingExamples = [50, 500, 1000, 2500]
spatialRes = [0.1, 0.25, 0.5, 1]
taxon = "Picea"


catName = "Basic"
cell = 0
for core in cores:
    for g in gb:
        for t in trainingExamples:
            for s in spatialRes:
                cell += 1
                for i in range(n):
                    expName =  "Experiement: ", cell, "(", catName, "). Running", core, " cores with ",g, "GB memory. Taxon is ", taxon, " training on: ",t, " examples at SR: ", s, " replicate #",i
                    print expName
                    data = (cell, i, core, g, taxon, t, s, catName)

                    sql = "INSERT INTO Experiments VALUES(DEFAULT, -1, %s, %s, %s, %s, %s, %s, %s, NULL,%s, 'NOT STARTED', DEFAULT, DEFAULT, DEFAULT);"
		    
		    cursor.execute(sql, data)
##Super
superConfs = [(16, 60), (32, 120), (32, 208)]
catName = "Super"
for conf in superConfs:
    for t in trainingExamples:
        for s in spatialRes:
            cell += 1
            for i in range(n):
                g = conf[1]
                core = conf[0]
                expName = 'NULL'#"Experiement: ", cell, "(", catName, "). Running", core, " cores with ",g, "GB memory. Taxon is ", taxon, " training on: ",t, " examples at SR: ", s, " replicate #",i
                print cell
                data = (cell, i, core, g, taxon, t, s, expName, catName)
                sql = "INSERT INTO Experiments VALUES(DEFAULT, -1, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'NOT STARTED', DEFAULT, DEFAULT, DEFAULT);"
                cursor.execute(sql, data)

## N sensitivity
catName = "nSensitivity"
trainingExamples = [100, 200, 300,400, 500, 600, 700,800, 900, 1000, 2000, 3000,
                    4000, 5000, 6000, 7000, 8000, 9000, 10000, 15000, 20000, 25000, 30000]
core = 4
g = 16
s = 0.25
for t in trainingExamples:
    cell += 1
    for i in range(n):
        expName = 'NULL'#"Experiement: ", cell, "(", catName, "). Running", core, " cores with ",g, "GB memory. Taxon is ", taxon, " training on: ",t, " examples at SR: ", s, " replicate #",i
        data = (cell, i, core, g, taxon, t, s, expName, catName)
        sql = "INSERT INTO Experiments VALUES(DEFAULT, -1, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'NOT STARTED',DEFAULT, DEFAULT, DEFAULT);"
        cursor.execute(sql, data)

## sSensitivity
catName = "sSensitivity"
t = 1000
core = 4
g = 16
spatialRes = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 2.5, 5]
for s in spatialRes:
    cell += 1
    for i in range(n):
        expName = 'NULL'#"Experiement: ", cell, "(", catName, "). Running", core, " cores with ",g, "GB memory. Taxon is ", taxon, " training on: ",t, " examples at SR: ", s, " replicate #",i
        print cell
        data = (cell, i, core, g, taxon, t, s, expName, catName)
        sql = "INSERT INTO Experiments VALUES(DEFAULT, -1, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'NOT STARTED', DEFAULT, DEFAULT, DEFAULT);"
        cursor.execute(sql, data)

## tSensitivity
catName = "tSensitivity"
taxa = ['Betula', "Picea", "Tsuga", "Quercus"]
t = 1000
s = 0.5
confs = [(1, 3.75), (2, 7.5), (4, 15), (8, 30), (16, 60), (32, 120)]
for c in confs:
    for taxon in taxa:
        cell += 1
        for i in range(n):
            core = c[0]
            g = c[1]
            expName = 'NULL' #"Experiement: ", cell, "(", catName, "). Running", core, " cores with ",g, "GB memory. Taxon is ", taxon, " training on: ",t, " examples at SR: ", s, " replicate #",i
            print cell
            data = (cell, i, core, g, taxon, t, s, expName, catName)
            sql = "INSERT INTO Experiments VALUES(DEFAULT, -1, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'NOT STARTED', DEFAULT, DEFAULT, DEFAULT);"
            cursor.execute(sql, data)

cnx.commit()
