#!/usr/local/bin/python

import sys
import subprocess
import pymysql

import login_details

STATS_FILE='/opt/speedchecker/vodafone-stats.csv'

def tail(file_path, n, offset=0):
    proc = subprocess.Popen(['tail', '-n', '%s' % (n + offset), file_path], stdout=subprocess.PIPE) 
    lines = proc.stdout.readlines()
    #return lines[:, -offset]
    return lines

lines = tail(STATS_FILE,1)

line = lines[0].rstrip().decode('utf-8')
if '#' in line:
    # skip lines with errors
    sys.exit(1)

#print(line)
stats=line.split(',')
#print(stats)
#"timestamp","IP","avg_speed","size","time"
timestamp=stats[0]
speed=stats[2]

#timestamp = strftime("%Y-%m-%d %H:%M:%S", localtime())

# Open database connection
try:
    connection = pymysql.connect(host=login_details.DB_HOST,user=login_details.DB_USER,password=login_details.DB_PASS,db=login_details.DB_NAME,charset='utf8',port=3306)
except Exception as e:
    print('db connection failed')
    print(e)
    sys.exit(1)

    #"pymysql.err.InternalError: Packet sequence number wrong - got 1 expected 0"
    # this is a BS error message !!!
    # i got this when i migrated to docker, the user/pass was not set up (it's f-all to do with threads and threadsafety)
    # setting up the user password and it worked fine


try:
    with connection.cursor() as cursor:
        # Create a new record
        sql = "INSERT INTO `speed` (`cdate`,`speed`) VALUES (%s, %s)"
        cursor.execute(sql, (timestamp, speed))

    # connection is not autocommit by default. So you must commit to save
    # your changes.
    connection.commit()

except Exception as e:
    print('insert failed')
    print(e)
    sys.exit(1)

finally:
    connection.close()

print("db insert ok")