#!/bin/bash

#
# 参考链接 https://blog.csdn.net/weixin_40461281/article/details/92586378
#

export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script!"
    exit 1
else
    if env |grep -q SUDO; then
        acme_sh_sudo="-f"
    fi
fi

echo "+-------------------------------------------+"
echo "|           docker install nginx            |"
echo "+-------------------------------------------+"
echo "|                                           |"
echo "+-------------------------------------------+"

#运行根目录，可以传参指定
BASE_PATH=$(cd `dirname $0`; pwd)
V_DATA='/volume';

#卸载原有的apache nginx
yum -y remove httpd nginx

#安装docker
if [ $(docker -h) ]; then
	#echo
	echo "docker nginx 已安装"
else
    yum -y install docker
fi

#开机启动
systemctl enable docker.service
#启动docker
systemctl restart docker.service
#拉取nginx镜像
docker pull nginx
#创建目录
mkdir -p ${V_DATA}/nginx/www/default ${V_DATA}/nginx/www ${V_DATA}/nginx/var/log ${V_DATA}/nginx/etc/nginx
#先建立nginx
docker run --name nginx-conf -p 80:80 -d nginx
#复制conf
docker cp nginx-conf:/etc/nginx ${V_DATA}/nginx/etc

#html
# docker cp nginx-conf:/usr/share/nginx/html/index.html ${V_DATA}/nginx/www/default
#stop nginx #删除 nginx镜像
docker stop nginx-conf && docker rm nginx-conf
#index.html
# echo "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><title>docker nginx</title></head><body><h1><center>docker nginx success!</center></h1><p><center>success!</center></p></body></html>" > /v_data/nginx/www/default/index.html
#stop nginx #删除 nginx镜像 先删除
if [ $(docker ps -aqf "name=nginx") ]; then
	docker stop nginx && docker rm nginx
fi
#启动正式的
docker run --name nginx -p 80:80 -p 443:443 -v ${V_DATA}/nginx/etc/nginx:/etc/nginx -v ${V_DATA}/nginx/var/log/nginx:/var/log/nginx -v ${V_DATA}/nginx/www:/www --restart=always -d nginx
#获得
CONTAINER_ID=$(docker ps -aqf "name=nginx")

if [ CONTAINER_ID ]; then
	#echo
	echo "docker nginx安装完成"
else
    echo "docker nginx安装失败!"
fi
