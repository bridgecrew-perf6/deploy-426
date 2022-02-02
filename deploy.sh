#!/bin/bash

REPOSITORY=/home/ec2-user/build

cd $REPOSITORY

echo "> 현재 구동중인 set 확인"
CURRENT_PROFILE=$(curl -s http://localhost/profile)
echo "> $CURRENT_CURRENT_PROFILE"

# 쉬고 있는 set 찾기: 하나의 set이 동작중이면 다른 set은 쉬고있음.
if [ "$CURRENT_PROFILE" == set1 ]
then
  IDLE_PROFILE=set2
  IDLE_PORT=8082
elif [ "$CURRENT_PROFILE" == set2 ]
then
  IDLE_PROFILE=set1
  IDLE_PORT=8081
else
  echo "> 일치하는 Profile이 없습니다. Profile: $CURRENT_PROFILE"
  echo "> set1을 할당합니다. IDLE_PROFILE=set1"
  IDLE_PROFILE=set1
  IDLE_PORT=8081
fi

JAR_NAME=$(ls $REPOSITORY/ | grep jar)

IDLE_APPLICATION=$IDLE_PROFILE-deploy.jar
cp "$JAR_NAME" ./$IDLE_APPLICATION

echo "> 프로덕션 프로퍼티 복사"
cp ../application.yml .

echo "> 현재 $IDLE_PROFILE 구동중인 애플리케이션 pid 확인"
IDLE_PID=$(pgrep -f $IDLE_APPLICATION)

if [ -z $IDLE_PROFILE ]
then
  echo "> 현재 구동중인 애플리케이션이 없으므로 종료하지 않습니다."
else
  echo "> kill -15 $IDLE_PID"
  kill -15 "$IDLE_PID"
  echo "> sleep 5 seconds..."
  sleep 5
fi

echo "> $IDLE_PROFILE 배포"
nohup java -jar -Dspring.profiles.active=$IDLE_PROFILE $IDLE_APPLICATION > app.log 2>&1 &

echo "> $IDLE_PROFILE 5초 후 Health Check 시작"
echo "> curl -s http::/localhost:$IDLE_PORT/health"
sleep 5

for retry_count in {1..10}
do
  response=$(curl -s http::/localhost:$IDLE_PORT/management/health)
  up_count=$(echo "$response" | grep 'UP' | wc -l)

  if [ $up_count -ge 1 ]
  then
    echo "> Health check 성공"
    break
  else
    echo "> Health check의 응답을 알 수 없거나 혹은 status가 UP이 아닙니다."
    echo "> Health check: ${response}"
  fi

  if [ "$retry_count" -eq 10 ]
  then
    echo "> Health check 실패"
    echo "> nginx에 연결하지 않고 배포를 종료합니다."
    exit 1
  fi

  echo "> Health check 연결 실패 재시도..."
  sleep 5
done
