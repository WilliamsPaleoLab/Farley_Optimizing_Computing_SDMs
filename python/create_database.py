##creates a sql database for using in the thesis
## WARNING: may overwrite existing databases and sql dumps

import sys
import logging

## read from the configuration file
import yaml

with open("/Users/scottsfarley/documents/thesis-scripts/conf/test.conf", 'r') as ymlfile:
    conf = yaml.load(ymlfile)

db_settings = conf['database']
host = db_settings['host']
user = db_settings['user']
pw = db_settings['pass']
db = db_settings['db'].lower()

## check how to log the results
logfile = conf['file_system']['log_loc']
loglevel = conf['logging']['current_level']
thisLevel = logging.getLevelName(loglevel)
logging.basicConfig(filename=logfile,level=thisLevel)

logging.info("Initiated database setup process.")


## make the user confirm, since we might overwrite something
print "Ready to create database: " \
      "\n\tUser: " + str(user) + "\n\tHostname: " + str(host) + "\n\tDatabase name: " + str(db)

check = raw_input("Do you want to continue with setup? [y/n]")
if check == 'y' or check == "Y":
    logging.info("User approved database setup.")
else:
    print "Okay.  Setup has been aborted."
    logging.warning("User quit database setup")
    sys.exit(-1)


## connect to the database server
import psycopg2
try:
    connection = psycopg2.connect(host=host, user=user, password=pw, dbname='postgres') ## use the default database here since we haven't created the new one yet
    connection.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
    cursor = connection.cursor()
    logging.info("Database connection successful.")
except:
    print "Failed to get database connection."
    logging.error("Failed to get database connection.")
    logging.info("Parameters were: Host: " + host + " User: " + user + " DB: " + db)
    sys.exit(-1)

##create a new database
sql = '''CREATE DATABASE ''' + db + ";"
try:
    cursor.execute(sql)
    logging.info("Created new database " + db)
    cursor.close() ## exit the current connection
    connection.close()
except Exception as e:
    connection.rollback()
    print "Failed to create new database: " + str(e)
    logging.error("Failed to create new database: " + str(e))
    sys.exit(-1)

## connect to the newest database
try:
     connection = psycopg2.connect(host=host, user=user, password=pw, dbname=db)
     cursor = connection.cursor()
     logging.info("Connected to new database.")
except Exception as e:
    print "Failed to connect to database: " + str(e)
    logging.error("Failed to create new database: " + str(e))

##create the tables
sql = '''CREATE TABLE experiments(
    experimentID serial,
    species text,
    memory integer,
    cores integer,
    npoints integer,
    resolution double precision,
    completed boolean,
    reps_completed integer,
    last_updated timestamp default current_timestamp,
    deviceid integer
    );
    CREATE TABLE results_timing(
    timingID serial,
    experimentID integer,
    repetition_number integer,
    overallSeconds double precision,
    fitSeconds double precision,
    predictSeconds double precision,
    accSeconds double precision,
    insertTime timestamp default current_timestamp
    );
    CREATE TABLE results_accuracy(
    accID serial,
    experimentID integer,
    repetition_number integer,
    AUC double precision,
    deviance double precision,
    specificity double precision,
    sensitivity double precision,
    insertTime timestamp default current_timestamp
    );
    CREATE TABLE devices(
    deviceID serial,
    baseCPUCount integer,
    baseMemory integer,
    networkSpeed double precision,
    CPUClockRate integer,
    owner text,
    description text
    );
    '''
try:
    cursor.execute(sql)
    logging.info("Done creating table structure.")
except Exception as e:
    print "Failed to create table structure: " + str(e)
    logging.error("Failed to create table structure: " + str(e))
    sys.exit(-1)

## now insert all the experiments into the experiments table
#
#figure out what the different experimental groups are from the conf file
npoints = conf['experiments']['n_point_options']
cores = conf['experiments']['core_options']
mem = conf['experiments']['memory_options']
sr = conf['experiments']['spatial_resolution_options']
nreps = conf['experiments']['num_reps'] ## integer not list
species = conf['experiments']['species_options']

i = 0
for s in species: ## species
    for n in npoints: ## number of points
        for c in cores: ## CPU Cores
            for m in mem: ## memory
                for r in sr: ## spatial resolution
                    ## insert into the experiments table
                    #     experimentID serial,
                    #     species text,
                    #     memory integer,
                    #     cores integer,
                    #     npoints integer,
                    #     resolution double precision,
                    #     completed boolean,
                    #     reps_completed integer
                    #     last_updated timestamp default current_timestamp,
                    #     deviceid integer
                    args = (s, m, c, n, r)
                    sql = "INSERT INTO experiments VALUES (DEFAULT,%s,%s,%s, %s, %s, FALSE, 0, DEFAULT, -1);"
                    try:
                        cursor.execute(sql, args)
                    except Exception as e:
                        connection.rollback()
                        print "Failed to insert into table experiments: " + str(e)
                        logging.error("Failed to insert into table experiments: " + str(e))
try:
    connection.commit()
    logging.info("Successfully created experiments table.")
except Exception as e:
    logging.error("Failed to commit changes to database: " + str(e))








