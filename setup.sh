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


mkdir -p $basedir/hsm-os/platform_version
cp -v $p2/platform_version/version.txt $basedir/hsm-os/platform_version/

configPath=$p1/config/display-config.ini

tempalte=$(grep 'base-template' $configPath  | awk '{print $3}' |tr -d '"')

echo template路径:$tempalte

if [ -z "$tempalte" ];then
    tempalte="nil"
fi

echo template路径:$tempalte

echo "hsm-sk install  -f $installpath -t $tempalte -b $basedir"

hsm-sk install  -f $installpath -t $tempalte --base $basedir

echo "$p1/xbase_Recovery.sh $basedir"

sleep 10


$p1/xbase_Recovery.sh $basedir

