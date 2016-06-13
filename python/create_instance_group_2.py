__author__ = 'scottsfarley'
import requests
import os
import apiclient
from oauth2client.client import GoogleCredentials
import pprint
import time

credentials = GoogleCredentials.get_application_default()

from googleapiclient import discovery
compute = discovery.build('compute', 'v1', credentials=credentials)


print credentials
print compute


def list_instances(compute, project, zone):
    result = compute.instances().list(project=project, zone=zone).execute()
    return result['items']

PROJECT = "thesis-1329"
ZONE = "us-central1-c"


def create_instance_template(compute, project, cores, GBMemory, name, description = "", tryToOverwrite=True):
    try:
        compute.instanceTemplates().delete(project=project, instanceTemplate=name, quiet=True).execute()
    except Exception as e:
        print str(e)
    mbMemory = GBMemory * 1024 ## to byte size
    machineType = "custom-" + str(cores) + "-" + str(mbMemory)
    rest = {
          "name": name,
          "description": description,
          "properties": {
            "machineType": machineType,
            "metadata": {
              "items": []
            },
            "tags": {
              "items": [
                "http-server",
                "https-server"
              ]
            },
            "disks": [
              {
                "type": "PERSISTENT",
                "boot": True,
                "mode": "READ_WRITE",
                "autoDelete": True,
                "deviceName": name,
                "initializeParams": {
                  "sourceImage": "projects/thesis-1329/global/images/boot-disk-6-7", ## boot from my startup disk
                  "diskType": "pd-standard",
                  "diskSizeGb": "10"
                }
              }
            ],
            "canIpForward": False,
            "networkInterfaces": [
              {
                "network": "projects/thesis-1329/global/networks/default",
                "accessConfigs": [
                  {
                    "name": "External NAT",
                    "type": "ONE_TO_ONE_NAT"
                  }
                ]
              }
            ],
            "scheduling": {
              "preemptible": True,
              "onHostMaintenance": "TERMINATE",
              "automaticRestart": False
            },
            "serviceAccounts": [
              {
                "email": "default",
                "scopes": [
                  "https://www.googleapis.com/auth/cloud-platform"
                ]
              }
            ]
          }
        }
    return compute.instanceTemplates().insert(
        project=project,
        body=rest).execute()


def deleteInstanceTemplate(compute, project, name):
    return compute.instanceTemplates().delete(
        project=project,
        instanceTemplate=name).execute()

def listInstanceTemplates(compute, project):
    response = compute.instanceTemplates().list(project=project).execute()
    pprint.pprint(response['items'])

def createInstanceGroup(template, size, groupName, tryToOverwrite=True):
    """The REST implementation doesnt seem to work, so use the command shell instead."""
    try:
        cmd = 'gcloud compute instance-groups managed delete ' + groupName + " --quiet"
        os.system(cmd)
        print "Deleted old instances"
    except Exception as e:
        print str(e)
    cmd = 'gcloud compute instance-groups managed create ' + groupName + ' --base-instance-name ' + groupName + ' --size ' + str(size) + ' --template ' + template + " --quiet"
    os.system(cmd)


def listInstanceGroups(compute, project, zone):
    """
    List all instance groups in the project
    """
    response = compute.instanceGroups().list(project=project, zone=zone).execute()
    pprint.pprint(response)
    return response

def deleteInstanceGroupCMD(groupName):
    cmd = 'gcloud compute instance-groups managed delete ' + groupName + " --quiet"
    os.system(cmd)

def deleteInstanceGroup(compute, project, zone, groupName):
    response = compute.instanceGroups().delete(project=project, zone=zone, instanceGroup=groupName).execute()
    pprint.pprint(response)
    return response


def wait_for_operation(compute, project, zone, operation):
    print('Waiting for operation to finish...')
    while True:
        result = compute.zoneOperations().get(
            project=project,
            zone=zone,
            operation=operation).execute()

        if result['status'] == 'DONE':
            print("done.")
            if 'error' in result:
                raise Exception(result['error'])
            return result

        time.sleep(1)


def createInstanceTemplateAndGroup(compute, project, zone, cores, gbMemory, groupSize):
    templateName = "template-" + str(cores) + "-" + str(gbMemory)
    groupName = "group-" + str(cores) + "-" + str(gbMemory)
    response = create_instance_template(compute, project, cores, gbMemory, templateName)
    operation = response['name']
    print operation
    try:
        wait_for_operation(compute, project, zone, operation)
    except:
        pass
    createInstanceGroup(templateName, groupSize, groupName)
    print "Created instance group " + groupName + " with " + str(groupSize) + " instances."

def getConfigCompletion(cores, memory):
    url = "http://104.154.235.236:8080/configstatus/" + str(cores) + "/" + str(memory)
    response = requests.get(url).json()
    percentComplete = response['data']['PercentCompleted']
    return percentComplete

def createAndManageGroup(compute, project, zone, cores, gbMemory, groupSize):
    ## create a group
    createInstanceTemplateAndGroup(compute, project, zone, cores, gbMemory, groupSize)
    percent = 0
    while percent < 100:
        percent = getConfigCompletion(cores, gbMemory)
        print percent
        time.sleep(30) ## wait one minute then poll again
    ## cleanup when operation is done
    groupName = "group-" + str(cores) + "-" + str(gbMemory)
    templateName = "template-" + str(cores) + "-" + str(gbMemory)
    operation = deleteInstanceGroup(compute, project, zone, groupName) ## kill the instance group
    wait_for_operation(compute, project, zone, operation['name'])
    deleteInstanceGroupCMD(groupName) ## delete the template
    print "Finished operation."
    return True


