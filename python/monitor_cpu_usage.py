import psutil
import time

while True:
    print "CPU Count: ", psutil.cpu_count()
    print "CPU Usage: ", psutil.cpu_percent(percpu=True)
    time.sleep(1)