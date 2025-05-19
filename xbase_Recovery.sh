#!/bin/bash


BASE_DIR=$1
if [ -z "$1" ];then
       echo "基础目录参数未传入,执行脚本退出"
       exit 1 
fi

id_file="/home/hsm-os/xbase_projectid"

# 检查ID文件是否存在
if [ -f "$id_file" ]; then
	echo -e "\e[33;1m===========================================================\e[0m"
	echo -e "\e[31;1m正在进行数据恢复,预计恢复时间10分钟左右,请耐心等待\e[0m"
	echo -e "\e[33;1m===========================================================\e[0m"
	id=$(cat "$id_file")
	sleep 30
	#  p://192.168.0.220:8000/hsm-install/v1/service/distribute?projectId=0650f98c99b3477fa5d1022c58bbb1a6
	sleep 5
	hsm-sk start nginx
	sleep 5
	echo "http://127.0.0.1:8000/hsm-install/v1/service/distribute?projectId=$id"
	echo "BASE_DIR:$BASE_DIR"
	$BASE_DIR/hsm-os/lib/curl "http://127.0.0.1:8000/hsm-install/v1/service/distribute?projectId=$id"
	echo " \n  "	
	echo -e "\e[31;1;5m正在进行数据恢复,请勿手动退出执行脚本！！！\e[0m"
	sleep 400
	rm -rf $id_file
	ls -l /home/hsm-os
	hsm-sk all | grep Fail  | awk '{print $2}' | sort -u | xargs -I {} hsm-sk restart {}
	sleep 10
	systemctl restart hsm-sk
	sleep 5
	hsm-sk all | grep StopFail  | awk '{print $2}' | sort -u | xargs -I {} hsm-sk stop {}
	sleep 10
	hsm-sk all | grep Fail  | awk '{print $2}' | sort -u | xargs -I {} hsm-sk start {}

else
	echo "ID file does not exist."
fi
