#!/bin/bash

#
# 参考链接 https://blog.csdn.net/weixin_40461281/article/details/92586378
#


#运行根目录，可以传参指定
BASE_PATH=$(cd `dirname $0`; pwd)
V_DATA='/volume';

#卸载原有的apache nginx
yum -y remove httpd nginx
#安装docker
yum -y install docker
#开机启动
systemctl enable docker.service
#启动docker
systemctl restart docker.service
#拉取nginx镜像
docker pull nginx
#创建目录
mkdir -p ${V_DATA}/nginx/www/default ${V_DATA}/nginx/logs ${V_DATA}/nginx/conf
#先建立nginx
docker run --name nginx-conf -p 80:80 -d nginx
#复制conf
docker cp nginx-conf:/etc/nginx/nginx.conf ${V_DATA}/nginx/conf
#stop nginx #删除 nginx镜像
docker stop nginx-conf && docker rm nginx-conf
#启动正式的
docker run --name nginx -p 80:80  -v ${V_DATA}/nginx/www/default:/usr/share/nginx/html -v ${V_DATA}/nginx/conf/nginx.conf:/etc/nginx/nginx.conf -v ${V_DATA}/nginx/logs:/var/log/nginx -d nginx 
#获得
#CONTAINER_ID=$(docker ps -aqf "name=containername")
#echo
echo "docker nginx安装完成"
