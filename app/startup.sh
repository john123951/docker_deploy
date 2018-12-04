#!/bin/bash

APP_HOME=/app

echo "Clean Env......"
if [ -d "${APP_HOME}/lib" ]; then
  rm -rf ${APP_HOME}/lib/*.jar
fi

echo "Init Env......"
if [ ! -d "${APP_HOME}/lib" ]; then
  mkdir ${APP_HOME}/lib
fi

echo "Downloading......"
wget ${MICROSERVICE_URL} -P ${APP_HOME}/lib

echo "Checking sum......"

echo "Decompressing......"

echo "Starting......"
cd ${APP_HOME}
./bin/run.sh start ${MICROSERVICE_ENV}
