#!/bin/bash

if [ $(whoami) != "root" ];then
    echo 需要root权限执行
    exit 1
fi

p1=$(cd $(dirname $0);pwd)
p2=$(dirname $p1)
cd $p2
pwd

#ip=$1
#if [ -z "$1" ];then
#    echo "请输入工程师站IP"
#    exit 1
#dev=$(ls -l /sys/class/net/ | sed 1d | grep -v virtual | awk '{print $9}')
#ip=$(ip -brief address show $dev | awk '{print $3}' | awk -F/ '{print $1}')
#if [ -z "$ip" ];then
#   echo "获取IP地址失败"
#   exit 1
#fi 
#fi

#pattern="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
#    if [[ $ip =~ $pattern ]];then
#      echo $ip
#    else
      # ip地址错误
#      echo "ip地址格式错误"
#      exit 1
#    fi

#str=$(ip -o -4 addr show | awk '{print $4}' | grep $ip | cut -d '/' -f 1)
#if [ "$str" != "$ip" ];then
#  echo "网卡中未找到指定IP:$ip"
#  exit 1
#fi


configPath=$p1/config/display-config.ini

basedir=$(grep 'base_dir' $configPath  | awk '{print $3}' |tr -d '"')

echo basedir路径:$basedir

if [ -z "$basedir" ];then
    basedir="/usr/local"
fi

echo basedir路径:$basedir


cd sk-install
echo 执行hsm-install.sh
./hsm-install.sh $basedir
if [ $? != 0 ]; then
 echo 执行hsm-install.sh错误
 exit 1
fi

cd $p2
installpath=$(ls -l eng-install | grep hsm-install | grep tar.gz | awk '{print $9}' | head -n1 )
if [ -z "$installpath" ];then
        echo 未找到hsm-install-x.x.x.tar.gz
        exit 1
fi
installpath=$p2/eng-install/$installpath
echo HSM-install路径:$installpath

p3=$basedir/hsm-os
cp -v eng-install/*.tar.gz $p3/pack
# cp -v base/*.tar.gz $p3/pack
# 将base下的应用包拷贝到pack目录下
find base/ -type f -name "*.tar.gz" -exec cp {} $p3/pack \;


cp -r -v $p2/license  $p3
chmod  755 $p3/license


mkdir -p $basedir/hsm-os/data/hsm-install/template
cp -r -v $p2/template/* $basedir/hsm-os/data/hsm-install/template

mkdir -p $basedir/hsm-os/data/hsm-install/solution
cp -v $p2/solution/*.ini $basedir/hsm-os/data/hsm-install/solution


configPath=$p1/config/display-config.ini

tempalte=$(grep 'base-template' $configPath  | awk '{print $3}' |tr -d '"')

echo template路径:$tempalte

if [ -z "$tempalte" ];then
    tempalte="nil"
fi

echo template路径:$tempalte

echo "hsm-sk install  -f $installpath -t $tempalte -b $basedir"

hsm-sk install  -f $installpath -t $tempalte --base $basedir

sleep 5

echo "recovery:$p1/xbase_Recovery.sh"

$p2/sk-install/xbase_Recovery.sh $basedir

#  p://192.168.0.220:8000/hsm-install/v1/service/distribute?projectId=0650f98c99b3477fa5d1022c58bbb1a6
# sleep 5 

# hsm-sk start nginx

# sleep 5 

# /usr/local/hsm-os/lib/curl "http://127.0.0.1:8000/hsm-install/v1/service/distribute?projectId=0650f98c99b3477fa5d1022c58bbb1a6"

# sleep 360

# hsm-sk all | grep Fail  | awk '{print $2}' | sort -u | xargs -I {} hsm-sk restart {}

# sleep 10

# systemctl restart hsm-sk 






