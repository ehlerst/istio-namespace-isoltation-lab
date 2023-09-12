#!/bin/bash


STARTDATE=$(date +%s%3N)

MODE=${MODE:-apply}
for i in `seq 1 100`;
do
  sed "s/_SEDME_/${i}/g" reviews.yaml | kubectl -n reviews $MODE -f -
done

ENDDATE=$(date +%s%3N)
until curl -H 'Content-Type: application/json' --connect-timeout 2 localhost:3000/api/annotations -d '{"dashboardUID":"3--MLVZZk", "time":'$STARTDATE', "timeEnd": '$ENDDATE',"text":"basic service '$MODE'"}'
do
  sleep 5
done

sleep 60
STARTDATE=$(date +%s%3N)
echo "starting big corperate labels"
for i in `seq 1 100`;
do
  sed "s/_SEDME_/${i}/g" reviews-biglabels.yaml | kubectl -n reviews $MODE -f -
done

ENDDATE=$(date +%s%3N)
until curl -H 'Content-Type: application/json' --connect-timeout 2 localhost:3000/api/annotations -d '{"dashboardUID":"3--MLVZZk", "time":'$STARTDATE', "timeEnd": '$ENDDATE',"text":"biglabels service '$MODE'"}'
do
  sleep 5
done


sleep 60
STARTDATE=$(date +%s%3N)
kubectl -n reviews rollout restart deployment reviews-v1
kubectl -n reviews rollout status deployment/reviews-v1 --timeout=60s
ENDDATE=$(date +%s%3N)
until curl -H 'Content-Type: application/json' --connect-timeout 2 localhost:3000/api/annotations -d '{"dashboardUID":"3--MLVZZk", "time":'$STARTDATE', "timeEnd": '$ENDDATE',"text":"rollout pods '$MODE'"}'
do
  sleep 5
done
