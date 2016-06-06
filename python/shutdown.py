import MySQLdb

keys = open("/keys.txt", 'r')
pw = keys.readlines()[0]

dbParams = open("/host.txt", 'r')
host = dbParams.readlines()[0]

cnx = MySQLdb.connect(unix_socket=host, user='root', db='timeSDM', passwd=pw)
cursor = cnx.cursor()
import socket
hostname = socket.gethostname()
sql = "SELECT SessionsManager.sessionID FROM SessionsManager INNER JOIN SessionsComputer on SessionsComputer.sessionID = SessionsManager.sessionID WHERE sessionStatus='STARTED' AND nodeName='" + str(hostname) + "' ORDER BY sessionStart DESC LIMIT 1;"
cursor.execute(sql)
row = cursor.fetchone()
sessionID = row[0]
sql = "UPDATE Experiments SET experimentStatus='INTERRUPTED', experimentLastUpdate=current_timestamp WHERE sessionID=" + str(sessionID) + " AND experimentStatus='STARTED';"
cursor.execute(sql)
sql = "UPDATE SessionsManager SET sessionStatus='INTERRUPTED', sessionEnd=current_timestamp WHERE sessionID=" + str(sessionID) + ";"
cursor.execute(sql)

