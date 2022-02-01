#!/bin/bash

pwd > /home/ec2-user/build/pwd.log

echo "> 현재 구동중인 애플리케이션 pid 확인"

CURRENT_PID=$(pgrep -f deploy*jar)

echo "> $CURRENT_PID"

if [ -z $CURRENT_PID ]; then
        echo "> 현재 구동중인 애플리케이션이 없으므로 종료하지 않습니다."
else
        echo "> kill -15 $CURRENT_PID"
        kill -15 $CURRENT_PID
        echo "> sleep 5 seconds..."
        sleep 5
fi

echo "> 새 애플리케이션 배포"

JAR_NAME=$(ls | grep jar)

echo "> JAR Name: $JAR_NAME"

nohup java -jar "$JAR_NAME" > app.log 2>&1 &
