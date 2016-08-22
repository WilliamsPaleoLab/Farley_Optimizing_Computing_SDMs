import psutil
import time
import MySQLdb
import datetime
## set globals

computerName = 'Instance-8-16'

cnx = MySQLdb.connect(host="104.154.235.236", user="Scripting", 
	passwd='Thesis-Scripting123!', db="timeSDM")
cursor = cnx.cursor()

print "Time\tAverageCPU\tUsed Memory\tAvailable Memory\tNum Procs\tSeconds Since Boot\t\n"

while True:
    cpuCount = psutil.cpu_count()
    cpuUsage = psutil.cpu_percent(percpu=True)
    cpuAvg = psutil.cpu_percent()
    cpuStats = psutil.cpu_stats()
    try:
        cpu1 = cpuUsage[0]
    except:
        cpu1 = None
    try:
        cpu2 = cpuUsage[1]
    except:
        cpu2 = None
    try:
        cpu3 = cpuUsage[2]
    except:
        cpu3 = None
    try:
        cpu4 = cpuUsage[3]
    except:
        cpu4 = None
    try:
        cpu5 = cpuUsage[4]
    except:
        cpu5 = None
    try:
        cpu6 = cpuUsage[5]
    except:
        cpu6 = None
    try:
        cpu7 = cpuUsage[6]
    except:
        cpu7 = None
    try:
        cpu8 = cpuUsage[7]
    except:
        cpu8 = None
    try:
        cpu9 = cpuUsage[8]
    except:
        cpu9 = None
    try:
        cpu10 = cpuUsage[9]
    except:
        cpu10 = None
    CPUSwitches = cpuStats.ctx_switches
    CPUInterrupts = cpuStats.interrupts
    memory = psutil.virtual_memory()
    memoryUsed = memory.used
    memoryPercent = memory.percent
    memoryAvailable = memory.available
    memoryTotal = memory.total
    procs = psutil.pids()
    numprocs = len(procs)
    bootTime = psutil.boot_time()
    now = time.time()
    secondsSinceBoot = now - bootTime
    st = datetime.datetime.fromtimestamp(now).strftime('%Y-%m-%d %H:%M:%S')
    sql = "INSERT INTO monitor values(default, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, default);"
    cursor.execute(sql, (computerName, cpuCount, cpu1, cpu2, cpu3, cpu4, cpu5, cpu6, cpu7, cpu8, cpu9, cpu10, cpuAvg, CPUSwitches, CPUInterrupts, memoryUsed, memoryPercent, memoryAvailable, secondsSinceBoot, memoryTotal, numprocs))
    print st, "\t", cpuAvg, "\t", memoryPercent, "\t", memoryAvailable, "\t", numprocs, "\t", secondsSinceBoot, "\t\n"
    cnx.commit()
    time.sleep(1)
