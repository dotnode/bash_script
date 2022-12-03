#!/bin/bash

#网站根目录，可以传参指定
WWWROOT=/home/wwwroot/server.ccrtd.com/public_html
BASE_PATH=$(cd `dirname $0`; pwd)
#拉取代码
cd ${WWWROOT}
git fetch --all
git reset --hard origin/master
git pull
LAST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)

date '+%Y-%m-%d %H:%M:%S' >> ${BASE_PATH}/dep.log
echo -e "最新版本tag:$LAST_TAG" >> ${BASE_PATH}/dep.log

git checkout ${LAST_TAG}
echo "{\"v\":\"$LAST_TAG\"}" > v.json

chmod -R 777 ${WWWROOT}
chown -R www:www ${WWWROOT}