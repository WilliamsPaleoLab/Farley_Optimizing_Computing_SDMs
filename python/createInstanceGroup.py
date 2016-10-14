
'''
gcloud compute --project "thesis-1329" instance-templates create
"instance-template-1"
--machine-type "n1-standard-1"
--network "default"
--no-restart-on-failure
--maintenance-policy "TERMINATE"
--preemptible
--scopes default="https://www.googleapis.com/auth/cloud-platform"
--tags "http-server","https-server"
--image "/thesis-1329/boot-disk-6-7"
--boot-disk-size "10"
--boot-disk-type "pd-standard"
--boot-disk-device-name "instance-template-1"
'''

'''gcloud compute
--project "thesis-1329" instance-templates create "instance-template-1"
--machine-type "custom-1-5376" --network "default"
--no-restart-on-failure --maintenance-policy "TERMINATE" --preemptible --scopes default="https://www.googleapis.com/auth/cloud-platform" --tags "http-server","https-server" --image "/thesis-1329/boot-disk-6-7" --boot-disk-size "10" --boot-disk-type "pd-standard" --boot-disk-device-name "instance-template-1"
'''

import os
import time
import sys
def createCustomInstanceTemplate(templateName, Cores, GBMem, project='thesis-1329', network='default', preemptible=True, image = "/thesis-1329/boot-disk-6-7",
                                 boot_disk_size= 10, boot_disk_type='pd-standard', boot_disk_device_name=""):
    '''Uses the gcloud command line to create a custom type machine instance on google cloud'''
    if boot_disk_device_name == "":
        boot_disk_device_name = templateName
    mbMemory = GBMem * 1024 ## to byte size

    cmd = '''gcloud compute --project "''' + project + '''" instance-templates create "''' + templateName \
          + '''" --machine-type "custom-''' + str(Cores) + '''-''' + str(mbMemory) \
          + '''" --network "default" --no-restart-on-failure --maintenance-policy "TERMINATE" --preemptible --scopes default="https://www.googleapis.com/auth/cloud-platform" --tags "http-server","https-server" --image "''' + image + '''" --boot-disk-size "''' + str(boot_disk_size) \
          + '''" --boot-disk-type "''' + boot_disk_type + '''" --boot-disk-device-name "''' + templateName + '''"'''

    print "Attempting to create new instance template."
    os.system(cmd)


def createPredefinedInstanceTemplate(templateName, typeName, project='thesis-1329', network='default', preemptible=True, image = "/thesis-1329/boot-disk-6-7",
                                 boot_disk_size= 10, boot_disk_type='pd-standard', boot_disk_device_name=""):
    '''Uses the gcloud command line to create a predefined machine type instance on google cloud'''
    if boot_disk_device_name == "":
        boot_disk_device_name = templateName
    mbMemory = GBMem * 1024 ## to byte size

    cmd = '''gcloud compute --project "''' + project + '''" instance-templates create "''' + templateName \
          + '''" --machine-type "''' + typeName \
          + '''" --network "default" --no-restart-on-failure --maintenance-policy "TERMINATE" --preemptible --scopes default="https://www.googleapis.com/auth/cloud-platform" --tags "http-server","https-server" --image "''' + image + '''" --boot-disk-size "''' + str(boot_disk_size) \
          + '''" --boot-disk-type "''' + boot_disk_type + '''" --boot-disk-device-name "''' + templateName + '''"'''

    print "Attempting to create new instance template."
    os.system(cmd)

def createInstanceGroup(groupName, template, size, project='thesis-1329', zone='us-central1-c', base_instance_name=''):
    '''Create an instance group of the desired size and from the desired template'''
    if base_instance_name == '':
        base_instance_name = groupName
    cmd = '''gcloud compute --project "''' + project + '''" instance-groups managed create "''' + groupName \
          + '''" --zone "''' + zone + '''" --base-instance-name "''' + base_instance_name + '''" --template "''' + template \
          + '''" --size "''' + str(size) + '''"'''
    print cmd
    os.system(cmd)

def deleteInstanceGroup(groupName):
    return

def gcloudAuth():
    os.system("gcloud auth login")

def autoStartCustomInstanceGroup(Cores, GBMemory, groupSize):
    templateName = "template-" + str(Cores) + "-" + str(GBMemory)
    groupName = "group-" + str(Cores) + "-" + str(GBMemory)
    createCustomInstanceTemplate(templateName, Cores, GBMemory)
    time.sleep(10)
    createInstanceGroup(groupName, templateName, groupSize)

#gcloudAuth()
autoStartCustomInstanceGroup(2, 3, 3)
