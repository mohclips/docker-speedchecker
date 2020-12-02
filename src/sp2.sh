#!/bin/bash

LOC=/opt/speedchecker
EMAIL="speedchecker_admin"

cat $LOC/src-dest | while read IP FILE URL; do

	if [[ "$IP" =~ ^\# ]] ; then
		continue
	fi	
#cat a | awk '

#echo $URL >&2
#echo $FILE
#echo $IP

#/usr/bin/time --output=/dev/stdout -p wget --tries=2 --output-file=/dev/stdout --timeout=10 --bind-address $IP -O /dev/null $URL | awk '
/usr/bin/time --output=/dev/stdout -p wget --tries=2 --output-file=/dev/stdout --timeout=10 -O /dev/null $URL | awk '
BEGIN {
#	print "Starting" > "/dev/stderr"
timestamp=0
IP=0
avg_speed=0
size=0
time=0
}
{
#print $0 > "/dev/stderr"
}
/connected/ {
#Connecting to www.mirrorservice.org (www.mirrorservice.org)|212.219.56.184|:80... connected.

split($4,arr,"|")
#print arr[2]"\n";
IP=arr[2] || 0;
}
/^--20..-..-.. ..:..:..--/ {
	#wget timestamp
	wtime=$1" "$2
	#print wtime > "/dev/stderr"
}

/saved/ {
# 1          2        3     4     5 6         7     8
# 2013-08-21 18:09:18 (73.4 KB/s) - /dev/null saved [1853752]
# 2013-09-11 06:53:17 (577 KB/s) - /dev/null saved [1872976]
# 2018-06-11 17:10:57 (2.11 MB/s) - ‘/dev/null’ saved [5092352/5092352]

#print "saved: "$0 > "/dev/stderr"

timestamp=$1" "$2;

avg_speed=$3;
sub(/\(/,"", avg_speed);
# make into bytes
avg_speed=avg_speed*8;


if ($4~/MB/) {
	avg_speed=avg_speed*1000;
}

#print "# avg_speed:", avg_speed > "/dev/stderr"

tsize=$8;
gsub(/[\[\]]/,"",tsize);
#print "tsize",tsize;
split(tsize,a,"/");
# array starts at 1  FFS!
#print "a[1]",a[1];
size=a[1];
}

/^real / {
#real	19.473
time=$2;
}

/^wget:/ {
	# normally an error message
	print "# "wtime" "$0 > "/dev/stderr"
	print "# "wtime" "$0
}

END { 

	if (avg_speed>30000) {
		size=0
	}

	if (size > 0) {
#		print timestamp","IP","avg_speed","size","time > "/dev/stderr"
		print timestamp","IP","avg_speed","size","time
		exit 0
	} else {
		print "# "wtime" we got an error" > "/dev/stderr"
		print "# "wtime" we got an error"	
		exit 1
	}
}
' >> $LOC/$FILE
	ERR=$?
	if [[ "$ERR" -ne "0" ]] ; then
		tail $LOC/$FILE | s-nail -s "speedchecker error" $EMAIL

		continue
	fi

	# write to docker logs
	tail -1 $LOC/$FILE
done
