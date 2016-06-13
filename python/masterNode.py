__author__ = 'scottsfarley'
import create_instance_group_2
import requests


def masterNode():
    while True:
        nextConfig = requests.get("http://104.154.235.236:8080/nextconfig").json()
        cores = nextConfig['data']['cores']
        memory = nextConfig['data']['GBMemory']
