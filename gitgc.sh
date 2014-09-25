#!/bin/sh

projects=`sed -f sed.sh /root/gitosis-admin/gitosis.conf | cut -d ' ' -f3-`
numbers=`echo ${projects} | awk '{print NF}'`

for ((i=1;i<=$numbers;i++)); do
	project=`echo ${projects} | cut -d ' ' -f${i}`
	
	if [ -d /root/gitback/${project}.git ]; then
		echo "[$(date +%Y%m%d%H%M%S)] start gc ${project}"
		cd /root/gitback/${project}.git
		git gc
		echo "[$(date +%Y%m%d%H%M%S)] end gc ${project}"
	fi
done

