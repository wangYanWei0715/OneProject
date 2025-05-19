#!/bin/bash

BASE_DIR=$1
if [ -z "$1" ];then
    echo "基础目录参数未传入,执行脚本退出"
    exit 1 
fi
# 获取当前脚本所在目录
#DIR="$( cd '$( dirname "${BASH_SOURCE[0]}" )' >/dev/null 2>&1 && pwd )"
DIR=$(dirname "$0")
# 指定系统内核程序名
SK="hsm-sk"
# 查询同级目录下所有文件名为 hsm-sk 的文件
SK_FILE=$(find $DIR -maxdepth 1 -type f -name "*$SK" -printf "%f" | head -n 1)
# 输出变量值
echo "SK程序文件名为: $SK_FILE"


# 根据选项执行相应操作
echo "安装SK服务"		
#拷贝系统内核程序至指定目录
sudo cp $DIR/$SK_FILE /usr/bin	
#为当前程序增加可执行权限
sudo chmod +x /usr/bin/$SK_FILE
#检查并初始化节点软件安装目录，并将系统内核注册为系统服务
echo "sk执行命令: $SK_FILE init --base $BASE_DIR"
sudo $SK_FILE init --base $BASE_DIR
#启动系统内核服务
sudo systemctl start $SK_FILE
echo "安装SK服务完成！"

#在当前目录下生成卸载脚本
#文件名称

file_name="$DIR/hsm-uninstall.sh"
# 组装文件内容
file_content+="#!/bin/bash \n"


file_content+="BASE_DIR_PARMA=\"\" \n"
file_content+="DELETE_FLAG=\"\" \n"
file_content+="BASE_DIR_I=/usr/local \n"

file_content+="FORCE_PARMA=\"--force\" \n"

file_content+="for arg in \"\$@\"; do \n"
file_content+="        echo \"\$arg\" \n"
file_content+="   if [ -d \"\$arg\" ]; then \n"
file_content+="     BASE_DIR_PARMA=\$arg \n"
file_content+="   fi \n"

file_content+="   if [[ ! -d \"\$arg\"  &&  \"\$arg\" == \"\$FORCE_PARMA\" ]]; then \n"
file_content+="      DELETE_FLAG=\$arg \n"
file_content+="   fi \n"
file_content+="done \n"

file_content+="if [ -z \"\$BASE_DIR_PARMA\" ]; then \n"
file_content+="    echo \"卸载脚本基础目录参数未传入，执行脚本退出\" \n"
file_content+="    exit 1 \n"
file_content+="fi \n"
file_content+="if [ -n \"\$BASE_DIR_PARMA\" ]; then \n"
file_content+="    BASE_DIR_I=\$BASE_DIR_PARMA \n"
file_content+="fi \n"
file_content+="if [ ! -d \"\$BASE_DIR_I/hsm-os/apps\" ];then \n"
file_content+="    echo \"卸载目录不存在请检查，执行脚本退出\" \n"
file_content+="    exit 1 \n"
file_content+="fi \n"
file_content+=" \n"

file_content+="echo -e  \"\033[31m  此脚本执行会卸载已部署平台环境，卸载前如需备份组态数据请移步至离线组态环境（IP:8000）项目列表页面,点击导出按钮备份需要的组态项目 \033[0m\" \n"

file_content+=" \n"

file_content+="while true; do \n"
file_content+="   read -p \"是否继续执行卸载脚本?(y/n):\" confirm \n"

file_content+="  if [[ \"\$confirm\" == \"y\" || \"\$confirm\" == \"Y\"  ]]; then \n"
file_content+="        echo \"开始执行卸载脚本\" \n"
file_content+="        break \n"
file_content+="  elif [[ \"\$confirm\" == \"n\" || \"\$confirm\" == \"N\"  ]]; then \n"
file_content+="       echo \"结束脚本，执行脚本退出\" \n"
file_content+="       exit 1 \n" 
file_content+="  else \n"
file_content+="        echo \"输入错误,请重新输入\" \n"
file_content+="  fi \n"
file_content+="done \n"




file_content+="echo \"执行sk卸载子命令\" \n"
file_content+="hsm-sk uninstall \n"
file_content+="echo \"停止hsm-sk项目\" \n"
file_content+="sudo systemctl stop hsm-sk \n"
file_content+="echo \"卸载pgsql\" \n"
file_content+="# 获取满足前缀模糊检索的文件夹列表的第一个 \n"
file_content+="folder=\$(find \"\$BASE_DIR_I/hsm-os/apps\" -type d -name \"postgresql14.8*\" | head -n 1) \n"
file_content+="echo \"\$folder\" \n"
file_content+="# 检查文件夹列表是否为空 \n"
file_content+="if [ -n \"\$folder\" ];then \n"
file_content+="  cd \$folder/bin \n"
file_content+=" HSM_HOME=\$BASE_DIR_I ./uninstall.sh 2> /dev/null \n"
file_content+="fi \n"
file_content+="# 获取满足前缀模糊检索的文件夹列表的第一个 \n"
file_content+="folder_keep=\$(find \"\$BASE_DIR_I/hsm-os/apps\" -type d -name \"keepalived2.2*\" | head -n 1) \n"
file_content+="echo \"\$folder_keep\" \n"
file_content+="# 检查文件夹列表是否为空 \n"
file_content+="if [ -n \"\$folder_keep\" ];then \n"
file_content+="  cd \$folder_keep/bin \n"
file_content+=" HSM_HOME=\$BASE_DIR_I ./stop.sh 2> /dev/null \n"
file_content+="fi \n"
file_content+="sudo rm -rf /etc/keepalived/* \n"

file_content+="echo \"卸载redis-6.2.11*\" \n"
file_content+="# 获取满足前缀模糊检索的文件夹列表的第一个 \n" 
file_content+="folder_redis=\$(find \"\$BASE_DIR_I/hsm-os/apps\" -type d -name \"redis-6.2.11*\" | head -n 1)  \n"
file_content+="echo \"\$folder_redis\" \n" 
file_content+="# 检查文件夹列表是否为空  \n"
file_content+="if [ -n \"\$folder_redis\" ];then  \n"
file_content+="  cd \$folder_redis/bin \n" 
file_content+=" HSM_HOME=\$BASE_DIR_I ./stop.sh 2> /dev/null \n" 
file_content+="fi  \n" 
file_content+="echo \"停止所有服务\" \n"
file_content+="sudo cat /sys/fs/cgroup/system.slice/hsm-sk.service/cgroup.procs |xargs kill -9 2> /dev/null \n"
file_content+="sudo cat /sys/fs/cgroup/hsmsk.slice/*/cgroup.procs |xargs kill -9 2> /dev/null \n"
file_content+="sudo cat /sys/fs/cgroup/systemd/system.slice/hsm-sk.service/tasks |xargs kill -9 2> /dev/null \n"
file_content+="sudo cat /sys/fs/cgroup/cpu/hsm_sk.slice/*/tasks  |xargs kill -9 2> /dev/null \n"
file_content+="sudo cat /sys/fs/cgroup/memory/hsm_sk.slice/*/tasks  |xargs kill -9 2> /dev/null \n"
file_content+="sudo pgrep containerd |xargs kill -9 2> /dev/null \n"
file_content+="echo \"卸载glusterfs10.1\" \n"
file_content+="# 获取满足前缀模糊检索的文件夹列表的第一个 \n"
file_content+="gfs=\$(find \"\$BASE_DIR_I/hsm-os/apps\" -type d -name \"glusterfs10.1*\" | head -n 1) \n"
file_content+="echo \"\$gfs\" \n"
file_content+="# 检查文件夹列表是否为空 \n"
file_content+="if [ -n \"\$gfs\" ];then \n"
file_content+="  cd \$gfs/bin \n"
file_content+=" HSM_HOME=\$BASE_DIR_I ./uninstall.sh 2> /dev/null \n"
file_content+="fi \n"
file_content+="echo \"取消ini文件隐藏属性\" \n"
file_content+="sudo chattr -i \$BASE_DIR_I/hsm-os/nodemanifest.ini 2> /dev/null \n"
file_content+="sudo chattr -i \$BASE_DIR_I/hsm-os/data/hsm-install/namespace.txt 2> /dev/null \n"
file_content+="echo \"删除hsm-os下的目录\" \n"
file_content+="sudo ip link del cni0 2> /dev/null \n"
file_content+="sudo ip link del hsmeth0 2> /dev/null \n"
file_content+="# sudo rm -rf \$BASE_DIR_I/hsm-os 2> /dev/null \n"
file_content+="echo  \"删除标记:\$DELETE_FLAG\" \n"
file_content+="  if [ \"\$DELETE_FLAG\" == \"\$FORCE_PARMA\" ]; then  \n"
file_content+="         sudo rm -rf \$BASE_DIR_I/hsm-os 2> /dev/null \n"
file_content+="  else \n"
file_content+="   TARGET_DIR=\"\$BASE_DIR_I/hsm-os\" \n"
file_content+="   grep projectId \$TARGET_DIR/nodemanifest.ini |  cut -d '=' -f2 | cut -d '\"' -f2 > /home/hsm-os/xbase_projectid \n"
file_content+="   cat /home/hsm-os/xbase_projectid \n"
file_content+="   find \$TARGET_DIR -mindepth 1 -maxdepth 1 ! -path \"\$TARGET_DIR/data\" -exec rm -rf {} + \n"
file_content+="   ls -l  \$TARGET_DIR/data \n"
file_content+="   find \$TARGET_DIR/data  -type f -name \"*.pid\" -exec rm -f {} \; \n"
file_content+="  fi \n"
file_content+="sudo rm -rf /opt/cni /etc/cni 2> /dev/null \n"
file_content+="echo \"删除influxdb配置文件\" \n"
file_content+="sudo rm -rf /root/.influxdbv2 2> /dev/null \n"
file_content+="sudo rm -f /usr/bin/hsm-sk 2> /dev/null \n"
file_content+="echo \"还原校时配置\" \n"
file_content+="if [ -e \"/etc/systemd/timesyncd.conf.bak\" ]; then \n"
file_content+="    sudo mv /etc/systemd/timesyncd.conf.bak /etc/systemd/timesyncd.conf \n"
file_content+="    sudo systemctl restart systemd-timesyncd.service \n"
file_content+="fi \n"
file_content+="sudo rm -f /etc/profile.d/hsmenvs.sh 2> /dev/null \n"
# 生成文件到当前目录
echo -e "$file_content" > "$file_name"
#给卸载脚本增加可执行权限
sudo chmod +x $file_name
echo "生成卸载脚本文件：$file_name"
