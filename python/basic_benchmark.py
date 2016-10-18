__author__ = 'scottsfarley'
import psutil
import datetime
import time

print "[Timestamp]\t[Core1]\t[Core2]\t[Core3]\t[Core4]\t[Available Memory]\t[Used Memory]\t[Memory Pct]"
while True:
    pct = psutil.cpu_percent(percpu=True)
    memory_avail = psutil.virtual_memory().available
    memory_used = psutil.virtual_memory().used
    memory_percent = psutil.virtual_memory().percent
    now = datetime.datetime.now()
    ts = now.strftime("%Y-%m-%d %H:%M:%S")
    print ts, "\t", pct[0], "\t", pct[1], '\t', pct[2], '\t', pct[3], '\t', memory_avail, '\t', memory_used, '\t', memory_percent
    time.sleep(1)