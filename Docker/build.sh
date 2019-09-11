#!/bin/bash

curDate=$(date +%d%m%Y)

docker build --network=host -t nlesc/lokum:${curDate} -t nlesc/lokum:latest .
#docker push nlesc/lokum:$curDate
