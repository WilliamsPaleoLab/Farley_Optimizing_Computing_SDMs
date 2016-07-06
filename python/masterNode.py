__author__ = 'scottsfarley'
from create_instance_group_2 import *
import requests
import os

outputPath = "/home/rstudio/thesis-scripts/modelOutput"


def masterNode(iters):
    i = 0
    while i < iters:
        nextConfig = requests.get("http://104.154.235.236:8080/nextconfig").json()
        cores = nextConfig['data'][0]['cores']
        memory = nextConfig['data'][0]['GBMemory']
        createAndManageGroup(compute, PROJECT, ZONE, cores, memory, 12)
        ## upload things to cloud storage
        for f in os.listdir(outputPath):
            img = f + "/" + outputPath
            cmd = "gsutil cp " + img + " gs://thesis-1329/" + f
            os.system(cmd)
            cmd = "rm img"
            os.system(cmd) ## remove the image
        print "Finished group iteration #", i


if __name__ == "__main__":
    masterNode(10000)
