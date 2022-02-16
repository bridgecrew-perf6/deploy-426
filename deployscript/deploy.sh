#!/bin/bash

REPOSITORY=/home/ec2-user/build

cd $REPOSITORY

echo ">> 현재 구동중인 애플리케이션 pid 확인"
CURRENT_PID=$(pgrep -f .jar)

echo ">> CURRENT_PID = $CURRENT_PID"

if [ -z "$CURRENT_PID" ]
then
  echo ">> 현재 구동중인 애플리케이션이 없습니다."
else
  echo ">> 구동중인 애플리케이션을 종료 합니다."
fi

for try_count in {1..10}
do
  PID=$(pgrep -f .jar)
  if [ -z "$PID" ]
  then
    break
  fi

  echo ">> try_count = $try_count"
  echo ">> kill -15 $PID"
  kill -15 "$PID"

  echo ">> sleep 0.2 seconds.."
  sleep 0.2

  if [ -z "$(pgrep -f .jar)" ]
  then
    echo ">> 구동중인 애플리케이션 종료 성공"
    break
  else
    if [ "$try_count" -eq 10 ]
    then
      echo ">> 구동중인 애플리케이션 종료를 실패했습니다."
      echo ">> 배포를 종료합니다."
      exit 1
    else
      echo ">> 다시 시도합니다."
    fi
  fi
done

echo ">> 새 애플리케이션 배포"
JAR_NAME=$(ls $REPOSITORY/ | grep jar)

if [ -z "$JAR_NAME" ]
then
  echo ">> jar 파일을 찾을 수 없습니다."
  echo ">> 배포를 종료합니다."
fi

echo ">> JAR_NAME = $JAR_NAME"
nohup java -jar "$JAR_NAME" > app.log 2>&1 &
sleep 3

NEW_PID=$(pgrep -f .jar)
if [ -z "$NEW_PID" ]; then
  echo ">> 새 애플리케이션 배포에 실패했습니다."
else
  echo ">> 새 애플리케이션 배포 성공 PID = $NEW_PID"
fi

echo ">> 배포 프로세스를 종료합니다."
