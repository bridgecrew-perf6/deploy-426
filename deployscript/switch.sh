#!/bin/bash

echo "> 현재 구동중인 set 확인"
CURRENT_PROFILE=$(curl -s http://localhost/profile)
echo "> $CURRENT_CURRENT_PROFILE"

# 쉬고 있는 set 찾기: 하나의 set이 동작중이면 다른 set은 쉬고있음.
if [ "$CURRENT_PROFILE" == set1 ]
then
  IDLE_PORT=8082
elif [ "$CURRENT_PROFILE" == set2 ]
then
  IDLE_PORT=8081
else
  echo "> 일치하는 Profile이 없습니다."
  echo "> 8081을 할당합니다. IDLE_PROFILE=set1"
  IDLE_PORT=8081
fi

echo "> 전환할 포트: $IDLE_PORT"
echo "> 포트 전환"
echo "set \$service_url http://127.0.0.1:${IDLE_PORT};" | sudo tee /etc/nginx/conf.d/service-url.inc

PROXY_PORT=$(curl -s http://localhost/profile)
echo "> Nginx current proxy port: $PROXY_PORT"

echo "> Nginx reload"
sudo service nginx reload
