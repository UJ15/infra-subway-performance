#!/bin/bash

txtrst='\033[1;37m' # White
txtred='\033[1;31m' # Red
txtylw='\033[1;33m' # Yellow
txtpur='\033[1;35m' # Purple
txtgrn='\033[1;32m' # Green
txtgra='\033[1;30m' # Gray

SHELL_SCRIPT_PATH=$(dirname $0)
EXECUTION_PATH=$(pwd)
PROJECT_NAME="infra-subway-performance"
PROJECT_PATH="$EXECUTION_PATH/$PROJECT_NAME"
BRANCH=$1
PROFILE=$2

if [[ $# -ne 2 ]]
then
    echo -e "${txtylw}=======================================${txtrst}"
    echo -e "${txtgrn}  << 스크립트 🧐 >>${txtrst}"
    echo -e ""
    echo -e "${txtgrn} $0 브랜치이름 ${txtred}{ prod | local }"
    echo -e "${txtylw}=======================================${txtrst}"
    exit
fi

echo -e "${txtylw}=======================================${txtrst}"
echo -e "${txtgrn}  << 스크립트 🧐 >>${txtrst}"
echo -e "${txtylw}=======================================${txtrst}"

function check_df() {
  cd ${PROJECT_PATH}

  git fetch
  master=$(git rev-parse $BRANCH)
  remote=$(git rev-parse origin/$BRANCH)

  if [[ $master == $remote ]]; then
    echo -e "[$(date)] Nothing to do!!! 😫"
    exit 0
  fi
}

function pull() {
  cd $EXECUTION_PATH

  echo -e ""
  echo -e ">> Pull Request 🏃♂️ "
  rm -rf $PROJECT_NAME
  git clone -b $BRANCH --single-branch https://github.com/handh0413/infra-subway-performance.git
}

function build() {
  cd $PROJECT_PATH

  echo -e ""
  echo -e ">> Build Project 🏃♂️ "
  ./gradlew clean build
}

function shutdown() {
  PID=`lsof -t -i:8080`
  if [ -n $PID ]; then
    `kill -9 $PID`
        echo -e ""
    echo -e ">> Shutdown Server 🏃♂️ "
  else
    echo -e ">> There is no running server 🏃♂️ "
  fi
}

function startup() {
  cd $EXECUTION_PATH
  APPLICATION=`find ./* -name "subway-0.0.1-SNAPSHOT.jar"`

  echo -e ""
  echo -e ">> Startup Server 🏃♂️ "
  `nohup java -jar -Dspring.profiles.active=$PROFILE $APPLICATION 1> application.log 2>&1 &`
}

// check_df;
pull;
build;
shutdown;
startup;
