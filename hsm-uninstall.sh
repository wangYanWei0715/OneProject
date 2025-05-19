#!/bin/bash 
BASE_DIR_PARMA="" 
DELETE_FLAG="" 
BASE_DIR_I=/usr/local 
FORCE_PARMA="--force" 
for arg in "$@"; do 
        echo "$arg" 
   if [ -d "$arg" ]; then 
     BASE_DIR_PARMA=$arg 
   fi 
   if [[ ! -d "$arg"  &&  "$arg" == "$FORCE_PARMA" ]]; then 
      DELETE_FLAG=$arg 
   fi 
done 
if [ -z "$BASE_DIR_PARMA" ]; then 
    echo "卸载脚本基础目录参数未传入，执行脚本退出" 
    exit 1 
fi 
if [ -n "$BASE_DIR_PARMA" ]; then 
    BASE_DIR_I=$BASE_DIR_PARMA 
fi 
if [ ! -d "$BASE_DIR_I/hsm-os/apps" ];then 
    echo "卸载目录不存在请检查，执行脚本退出" 
    exit 1 
fi 
 
echo -e  "[31m  此脚本执行会卸载已部署平台环境，卸载前如需备份组态数据请移步至离线组态环境（IP:8000）项目列表页面,点击导出按钮备份需要的组态项目 [0m" 
 
while true; do 
   read -p "是否继续执行卸载脚本?(y/n):" confirm 
  if [[ "$confirm" == "y" || "$confirm" == "Y"  ]]; then 
        echo "开始执行卸载脚本" 
        break 
  elif [[ "$confirm" == "n" || "$confirm" == "N"  ]]; then 
       echo "结束脚本，执行脚本退出" 
       exit 1 
  else 
        echo "输入错误,请重新输入" 
  fi 
done 
echo "执行sk卸载子命令" 
hsm-sk uninstall 
echo "停止hsm-sk项目" 
sudo systemctl stop hsm-sk 
echo "卸载pgsql" 
# 获取满足前缀模糊检索的文件夹列表的第一个 
folder=$(find "$BASE_DIR_I/hsm-os/apps" -type d -name "postgresql14.8*" | head -n 1) 
echo "$folder" 
# 检查文件夹列表是否为空 
if [ -n "$folder" ];then 
  cd $folder/bin 
 HSM_HOME=$BASE_DIR_I ./uninstall.sh 2> /dev/null 
fi 
# 获取满足前缀模糊检索的文件夹列表的第一个 
folder_keep=$(find "$BASE_DIR_I/hsm-os/apps" -type d -name "keepalived2.2*" | head -n 1) 
echo "$folder_keep" 
# 检查文件夹列表是否为空 
if [ -n "$folder_keep" ];then 
  cd $folder_keep/bin 
 HSM_HOME=$BASE_DIR_I ./stop.sh 2> /dev/null 
fi 
sudo rm -rf /etc/keepalived/* 
echo "卸载redis-6.2.11*" 
# 获取满足前缀模糊检索的文件夹列表的第一个 
folder_redis=$(find "$BASE_DIR_I/hsm-os/apps" -type d -name "redis-6.2.11*" | head -n 1)  
echo "$folder_redis" 
# 检查文件夹列表是否为空  
if [ -n "$folder_redis" ];then  
  cd $folder_redis/bin 
 HSM_HOME=$BASE_DIR_I ./stop.sh 2> /dev/null 
fi  
echo "停止所有服务" 
sudo cat /sys/fs/cgroup/system.slice/hsm-sk.service/cgroup.procs |xargs kill -9 2> /dev/null 
sudo cat /sys/fs/cgroup/hsmsk.slice/*/cgroup.procs |xargs kill -9 2> /dev/null 
sudo cat /sys/fs/cgroup/systemd/system.slice/hsm-sk.service/tasks |xargs kill -9 2> /dev/null 
sudo cat /sys/fs/cgroup/cpu/hsm_sk.slice/*/tasks  |xargs kill -9 2> /dev/null 
sudo cat /sys/fs/cgroup/memory/hsm_sk.slice/*/tasks  |xargs kill -9 2> /dev/null 
sudo pgrep containerd |xargs kill -9 2> /dev/null 
echo "卸载glusterfs10.1" 
# 获取满足前缀模糊检索的文件夹列表的第一个 
gfs=$(find "$BASE_DIR_I/hsm-os/apps" -type d -name "glusterfs10.1*" | head -n 1) 
echo "$gfs" 
# 检查文件夹列表是否为空 
if [ -n "$gfs" ];then 
  cd $gfs/bin 
 HSM_HOME=$BASE_DIR_I ./uninstall.sh 2> /dev/null 
fi 
echo "取消ini文件隐藏属性" 
sudo chattr -i $BASE_DIR_I/hsm-os/nodemanifest.ini 2> /dev/null 
sudo chattr -i $BASE_DIR_I/hsm-os/data/hsm-install/namespace.txt 2> /dev/null 
echo "删除hsm-os下的目录" 
sudo ip link del cni0 2> /dev/null 
sudo ip link del hsmeth0 2> /dev/null 
# sudo rm -rf $BASE_DIR_I/hsm-os 2> /dev/null 
echo  "删除标记:$DELETE_FLAG" 
  if [ "$DELETE_FLAG" == "$FORCE_PARMA" ]; then  
         sudo rm -rf $BASE_DIR_I/hsm-os 2> /dev/null 
  else 
   TARGET_DIR="$BASE_DIR_I/hsm-os" 
   grep projectId $TARGET_DIR/nodemanifest.ini |  cut -d '=' -f2 | cut -d '"' -f2 > /home/hsm-os/xbase_projectid 
   cat /home/hsm-os/xbase_projectid 
   find $TARGET_DIR -mindepth 1 -maxdepth 1 ! -path "$TARGET_DIR/data" -exec rm -rf {} + 
   ls -l  $TARGET_DIR/data 
   find $TARGET_DIR/data  -type f -name "*.pid" -exec rm -f {} \; 
  fi 
sudo rm -rf /opt/cni /etc/cni 2> /dev/null 
echo "删除influxdb配置文件" 
sudo rm -rf /root/.influxdbv2 2> /dev/null 
sudo rm -f /usr/bin/hsm-sk 2> /dev/null 
echo "还原校时配置" 
if [ -e "/etc/systemd/timesyncd.conf.bak" ]; then 
    sudo mv /etc/systemd/timesyncd.conf.bak /etc/systemd/timesyncd.conf 
    sudo systemctl restart systemd-timesyncd.service 
fi 
sudo rm -f /etc/profile.d/hsmenvs.sh 2> /dev/null 

