__author__ = 'scottsfarley'
from create_instance_group_2 import *
import requests


def masterNode(iters):
    i = 0
    while i < iters:
        nextConfig = requests.get("http://104.154.235.236:8080/nextconfig").json()
        cores = nextConfig['data']['cores']
        memory = nextConfig['data']['GBMemory']
        createAndManageGroup(compute, PROJECT, ZONE, cores, memory, 3)
        print "Finished group iteration #", i


if __name__ == "__main__":
    masterNode(100)

