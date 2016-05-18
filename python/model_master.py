## controls model run execution

## Import modules
import psycopg2
import logging
import psutil
import rpy2
import sys
import platform
import datetime
import yaml
import rpy2.robjects
import rpy2.interactive
from rpy2.robjects import packages
from rpy2.robjects import vectors
from rpy2.robjects import r
from rpy2.robjects.vectors import DataFrame
from rpy2.robjects.packages import importr, data
import time


class ModelMaster:
    def __init__(self, configLocation):
        self.readConfig(configLocation)
        self.setupLogging()
        self.connectToDatabase()

    def connectToDatabase(self):
        ## database settings from configuration file
        try:
            self.db_settings = self.conf['database']
            host = self.db_settings['host']
            user = self.db_settings['user']
            pw = self.db_settings['pass']
            db = self.db_settings['db'].lower()
            logging.info("Accessed database properties from conf file: DONE.")
        except AttributeError:
            print "Failed to access database properties."
            logging.error("Accessed database properties from conf file: ERROR.")

        ## do connection
        try:
            self.dbconnection = psycopg2.connect(host=host, user=user, password=pw, dbname=db) ## use the default database here since we haven't created the new one yet
            self.dbcursor = self.dbconnection.cursor()
            logging.info("Connected to database: DONE." )
            print "Connected to database: DONE."
        except:
            print "Failed to get database connection."
            logging.critical("Connected to database: ERROR.")
            logging.info("Parameters were: Host: " + host + " User: " + user + " DB: " + db)
            sys.exit(-1)

    def readConfig(self, fileLocation):
        ## Read a configuration file from the disk
        try:
            with open(fileLocation, 'r') as ymlfile:
                conf = yaml.load(ymlfile)
                self.conf = conf
        except:
            print "Failed to read in configuration file."
            sys.exit(1)

    def getNextExperiment(self):
        '''Gets the next uncompleted experiment within this computer's hardware ability'''
        sql = "SELECT * FROM experiments WHERE cores <= %s and memory <= %s AND completed = FALSE LIMIT 1;"
        ncores = self.logicalCores
        nmemory = self.totalMemory
        self.dbcursor.execute(sql, (ncores, nmemory))
        row = self.dbcursor.fetchone()
        if row is None:
            print "No valid experiments found."
            logging.info("No valid experiments found.")
            return False
        else:
            print "Found valid experiment.  #", row[0]
            self.currentExperiment = row
            self.currentExperimentID = row[0]


    def setupLogging(self):
        logfile = self.conf['file_system']['log_loc']
        loglevel = self.conf['logging']['current_level']
        thisLevel = logging.getLevelName(loglevel)
        logging.basicConfig(filename=logfile,level=thisLevel)
        logging.info("Setting up new Model instance.  Starting log...")

    def loadPredictors(self):
        try:
            rcode = "predictors <- read.csv('%s')" % self.conf['conf']['path']
            r(rcode) ## sets the predictors into the r environment
            logging.info("Loading predictor variables: DONE.")
        except Exception as e:
            print "Error loading predictor variables: " + str(e)
            logging.critical("Loading predictor variables: ERROR.")
            logging.info("Error message: " + str(e))

    def loadOccurrences(self, species):
        try:
            rcode = "occ <- read.csv('%s')" % self.conf['file_system'][species]
            r(rcode)
            logging.info("Loading occurrence matrix: DONE.")
        except Exception as e:
            print "Error loading occurrence matrix: " + str(e)
            logging.critical("Loading occurrence matrix: ERROR.")
            logging.info("Error message: "+ str(e))


    def getHardwareProps(self):
        self.logicalCores = psutil.cpu_count()
        self.physicalCores = psutil.cpu_count(logical=False)
        self.totalMemory = psutil.virtual_memory().total
        self.availableMemory = psutil.virtual_memory().available
        self.memoryUsePct = psutil.virtual_memory().percent
        self.freeMemory = psutil.virtual_memory().free
        self.usedMemory = psutil.virtual_memory().used
        self.swapMemory = psutil.swap_memory().total
        self.swapUsePct = psutil.swap_memory().percent
        self.boottime = psutil.boot_time()
        self.timeSinceBoot = datetime.datetime.now() - datetime.datetime.fromtimestamp(self.boottime)
        self.architecture = platform.architecture()[0]
        self.machineType = platform.machine()
        self.platformString = platform.platform()
        self.networkName = platform.node()
        self.processorType = platform.processor()
        self.OS = platform.system()
        return
    def getCurrentCPUPercent(self):
        return psutil.cpu_percent(interval=1, percpu=True)
    def measureHardwareProps(self, iterations):
        data = []
        i = 0
        while i < iterations:
            props = {
                'availableMemory' : psutil.virtual_memory().available,
                'freeMemory' : psutil.virtual_memory().free,
                'usedMemory': psutil.virtual_memory().used,
                'memoryPercent' : psutil.virtual_memory().percent,
                'CPUUsage' : psutil.cpu_percent(percpu=True)
            }
            data.append(props)
            time.sleep(0.5)
            i += 1
        return data

    def setMemoryAllocation(self):
        return
    def setCPUAllocation(self):
        return
    def sampleTestSet(self):
        return
    def runExperiment(self):
        return
    def submitExperimentToDatabase(self):
        return
