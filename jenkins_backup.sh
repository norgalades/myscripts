#!/bin/bash
source "$JENKINS_HOME"/user_scripts/base.sh
mytime="$(date +_%y%m%d_%H%M%S)"
#Create dest folder (if it doesn't yet exsist) for the backup archives in ncesplksh02 and ncesecdfir03
ssh -o StrictHostKeyChecking=no root@dest1.net -- mkdir -p /opt/others/ || exit 1
ssh -o StrictHostKeyChecking=no root@dest2.net -- mkdir -p /opt/others/ || exit 1

for server in server-list ; do
	echo_green "$server"
	echo_cyan "$dash_line"
	ssh -o StrictHostKeyChecking=no root@"$server" -- mkdir -p /backup/ || exit 1
	#Connect and create the archive with the folders that need to be backuped
	ssh -o StrictHostKeyChecking=no root@"$server" -- umask 0027 \; tar cfzh /backup/thehive_"${server}${mytime}".tgz -C / opt/thehive etc/thehive etc/elasticsearch etc/cortex
	#Keep the archives of the last 7 days 
	ssh -o StrictHostKeyChecking=no root@"$server" -- find /backup/ -name "thehive*.tgz" -ctime +7 -delete
	#Copy the just created archive into ncesplksh02 and ncesecdfir03 server
	scp -o StrictHostKeyChecking=no -3 root@"$server":/backup/thehive_"${server}${mytime}".tgz root@dest1.net:/opt/others/
	scp -o StrictHostKeyChecking=no -3 root@"$server":/backup/thehive_"${server}${mytime}".tgz root@dest2.net:/opt/others/    
	ssh -o StrictHostKeyChecking=no root@"$server" -- cat /opt/backup_log.log
	echo_cyan "$dash_line"
done

#Delete all the backup archives older than 30 days from ncesplksh02 and ncesecdfir03
ssh -o StrictHostKeyChecking=no root@dest1.net -- find /opt/others/ -name "thehive*.tgz" -ctime +30 -delete
ssh -o StrictHostKeyChecking=no root@dest2.net -- find /opt/others/ -name "thehive*.tgz" -ctime +30 -delete