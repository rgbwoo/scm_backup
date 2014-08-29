#!/bin/sh

if [ ! -d /root/gitback/gitosis-admin ]; then
	echo -e "[$(date +%Y%m%d%H%M%S)] start clone gitosis-admin" >> /root/gitback/git_back.log 
	git clone git@192.168.10.106:gitosis-admin.git >> /root/gitback/git_back.log
	echo -e "[$(date +%Y%m%d%H%M%S)] end colne gitosis-admin" >> /root/gitback/git_back.log
else
	echo -e "[$(date +%Y%m%d%H%M%S)] start update gitosis-admin" >> /root/gitback/git_back.log
	cd /root/gitback/gitosis-admin
	git pull >> /root/gitback/git_back.log
	cd /root/gitback
	echo -e "[$(date +%Y%m%d%H%M%S)] end update gitosis-admin" >> /root/gitback/git_back.log
fi


projects=`sed -f sed.sh /root/gitback/gitosis-admin/gitosis.conf | cut -d ' ' -f3-`
numbers=`echo ${projects} | awk '{print NF}'`

for ((i=1;i<=$numbers;i++)); do
	project=`echo ${projects} | cut -d ' ' -f${i}`
	
	if [ ! -d /root/gitback/${project} ]; then
		echo -e "[$(date +%Y%m%d%H%M%S)] start clone ${project}" >> /root/gitback/git_back.log
		git clone git@192.168.10.106:${project}.git >> /root/gitback/git_back.log
		echo -e "[$(date +%Y%m%d%H%M%S)] end clone ${project}" >> /root/gitback/git_back.log
	else
		echo -e "[$(date +%Y%m%d%H%M%S)] start update ${project}" >> /root/gitback/git_back.log
		cd /root/gitback/${project}
		git pull >> /root/gitback/git_back.log
		cd /root/gitback
		echo -e "[$(date +%Y%m%d%H%M%S)] end update ${project}" >> /root/gitback/git_back.log
	fi
done

