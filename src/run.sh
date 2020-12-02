#!/bin/sh

# 15mins
SLEEP=15m

cd /opt/speedchecker

while true; do

        #TODO: log rotation

        # run wget pull
        ./sp2.sh 

        #get last entry and save to db
        ./insert_db.py

        sleep $SLEEP
done