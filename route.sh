#!/bin/bash

route -n | grep UG | grep -v ^0 | awk '{print $1,$3}' >a.txt

ip=`ip a | grep eth0 | grep inet |awk -F '/' '{print $1}'|awk '{print $2}'`

service_net="10.1.0.0"
service_mask="255.255.255.255"

#判断route.rule文件是否存在
if [ -f route.rule ];then
  >route.rule
fi

#生成route.rule文件
#添加coredns的路由
echo "route add -net $service_net  netmask $service_mask gw $ip" >route.rule

while read NT MK
do
  echo "route add -net $NT netmask $MK gw $ip " >>route.rule
done < a.txt

#删除临时文件
rm -rf a.txt