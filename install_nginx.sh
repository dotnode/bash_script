#!/bin/bash

#
# 参考链接 https://blog.csdn.net/weixin_40461281/article/details/92586378
#

export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
        if grep -Eq "CentOS Stream" /etc/*-release; then
            isCentosStream='y'
        fi
    elif grep -Eqi "Alibaba" /etc/issue || grep -Eq "Alibaba Cloud Linux" /etc/*-release; then
        DISTRO='Alibaba'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun Linux" /etc/*-release; then
        DISTRO='Aliyun'
        PM='yum'
    elif grep -Eqi "Amazon Linux" /etc/issue || grep -Eq "Amazon Linux" /etc/*-release; then
        DISTRO='Amazon'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        PM='yum'
    elif grep -Eqi "Oracle Linux" /etc/issue || grep -Eq "Oracle Linux" /etc/*-release; then
        DISTRO='Oracle'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux" /etc/issue || grep -Eq "Red Hat Enterprise Linux" /etc/*-release; then
        DISTRO='RHEL'
        PM='yum'
    elif grep -Eqi "rockylinux" /etc/issue || grep -Eq "Rocky Linux" /etc/*-release; then
        DISTRO='Rocky'
        PM='yum'
    elif grep -Eqi "almalinux" /etc/issue || grep -Eq "AlmaLinux" /etc/*-release; then
        DISTRO='Alma'
        PM='yum'
    elif grep -Eqi "openEuler" /etc/issue || grep -Eq "openEuler" /etc/*-release; then
        DISTRO='openEuler'
        PM='yum'
    elif grep -Eqi "Anolis OS" /etc/issue || grep -Eq "Anolis OS" /etc/*-release; then
        DISTRO='Anolis'
        PM='yum'
    elif grep -Eqi "Kylin Linux Advanced Server" /etc/issue || grep -Eq "Kylin Linux Advanced Server" /etc/*-release; then
        DISTRO='Kylin'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='apt'
    elif grep -Eqi "Deepin" /etc/issue || grep -Eq "Deepin" /etc/*-release; then
        DISTRO='Deepin'
        PM='apt'
    elif grep -Eqi "Mint" /etc/issue || grep -Eq "Mint" /etc/*-release; then
        DISTRO='Mint'
        PM='apt'
    elif grep -Eqi "Kali" /etc/issue || grep -Eq "Kali" /etc/*-release; then
        DISTRO='Kali'
        PM='apt'
    elif grep -Eqi "UnionTech OS" /etc/issue || grep -Eq "UnionTech OS" /etc/*-release; then
        DISTRO='UOS'
        if command -v apt >/dev/null 2>&1; then
            PM='apt'
        elif command -v yum >/dev/null 2>&1; then
            PM='yum'
        fi
    elif grep -Eqi "Kylin Linux Desktop" /etc/issue || grep -Eq "Kylin Linux Desktop" /etc/*-release; then
        DISTRO='Kylin'
        PM='yum'
    else
        DISTRO='unknow'
    fi
    Get_OS_Bit
}

Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        Is_64bit='y'
        ARCH='x86_64'
        DB_ARCH='x86_64'
    else
        Is_64bit='n'
        ARCH='i386'
        DB_ARCH='i686'
    fi

    if uname -m | grep -Eqi "arm|aarch64"; then
        Is_ARM='y'
        if uname -m | grep -Eqi "armv7|armv6"; then
            ARCH='armhf'
        elif uname -m | grep -Eqi "aarch64"; then
            ARCH='aarch64'
        else
            ARCH='arm'
        fi
    fi
}

Color_Text()
{
  echo -e " \e[0;$2m$1\e[0m"
}

Echo_Red()
{
  echo $(Color_Text "$1" "31")
}

Echo_Green()
{
  echo $(Color_Text "$1" "32")
}

# Check if user is root
if [ $(id -u) != "0" ]; then
    Echo_Red "Error: You must be root to run this script!"
    exit 1
fi

Get_Dist_Name
if [ "${DISTRO}" = "unknow" ]; then
    Echo_Red "Unable to get Linux distribution name, or do NOT support the current distribution."
    exit 1
fi

clear
echo "+-------------------------------------------+"
echo "     docker install nginx for ${DISTRO}      "
echo "+-------------------------------------------+"


#运行根目录，可以传参指定
BASE_PATH=$(cd `dirname $0`; pwd)
V_DATA='/volume';

if [ "$PM" = "yum" ]; then
    yum -y remove httpd* nginx
    yum clean all
elif [ "$PM" = "apt" ]; then
    apt-get --purge remove apache2.2
    apt-get --purge remove apache2-doc
    apt-get --purge remove apache2-utils
    apt-get autoremove -y && apt-get clean
fi

#安装docker
if [[ $(docker -h) ]]; then
	#echo
	echo "docker 已安装"
else
    curl -fsSL https://get.docker.com | bash -s docker
fi

#开机启动
systemctl enable docker.service
#启动docker
systemctl restart docker.service
#拉取nginx镜像
docker pull nginx
#创建目录
mkdir -p ${V_DATA}/nginx/www/default ${V_DATA}/nginx/www ${V_DATA}/nginx/var/log ${V_DATA}/nginx/etc/nginx

#echo
#先建立nginx
docker run --name nginx-conf -d nginx
#复制conf
docker cp nginx-conf:/etc/nginx ${V_DATA}/nginx/etc
#stop nginx #删除 nginx镜像
docker stop nginx-conf && docker rm nginx-conf

#stop nginx #删除 nginx镜像 先删除
if [[ $(docker ps -aqf "name=nginx") ]]; then
	docker stop nginx && docker rm nginx
fi
#启动正式的
docker run --name nginx -p 80:80 -p 443:443 -v ${V_DATA}/nginx/etc/nginx:/etc/nginx -v ${V_DATA}/nginx/var/log/nginx:/var/log/nginx -v ${V_DATA}/nginx/www:/www --restart=always -d nginx
#获得
CONTAINER_ID=$(docker ps -aqf "name=nginx")

if [[ CONTAINER_ID ]]; then
	#echo
	Echo_Green "docker nginx安装完成"
else
    Echo_Red "docker nginx安装失败!"
fi
