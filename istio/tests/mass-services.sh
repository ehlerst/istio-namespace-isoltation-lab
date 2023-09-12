#!/bin/bash
PAUSE=${PAUSE:-60}
annotate_grafana () {
  STARTDATE=$1
  ENDDATE=$2
  shift 2
  TEXT=$*
  until curl -H 'Content-Type: application/json' --connect-timeout 2 localhost:3000/api/annotations -d '
    {
      "dashboardUID":"3--MLVZZk", 
      "time":'$STARTDATE', 
      "timeEnd": '$ENDDATE',
      "text": "'"$TEXT"'"
      }
  '
  do
    sleep 5
  done

}


STARTDATE=$(date +%s%3N)
## Add basic
for i in `seq 1 100`;
do
  sed "s/_SEDME_/${i}/g" pause.yaml | kubectl -n pause apply -f -
done

ENDDATE=$(date +%s%3N)
annotate_grafana $STARTDATE $ENDDATE "basic service apply"
sleep $PAUSE

STARTDATE=$(date +%s%3N)
kubectl -n pause rollout restart deployment pause
kubectl -n pause rollout status deployment pause --timeout=60s
ENDDATE=$(date +%s%3N)
annotate_grafana $STARTDATE $ENDDATE "rollout basic service"
sleep $PAUSE
sleep $PAUSE

## Remove basic so we have a clean biglabel
STARTDATE=$(date +%s%3N)
for i in `seq 1 100`;
do
  sed "s/_SEDME_/${i}/g" pause.yaml | kubectl -n pause delete -f -
done
ENDDATE=$(date +%s%3N)
annotate_grafana $STARTDATE $ENDDATE "basic service delete"
sleep $PAUSE

STARTDATE=$(date +%s%3N)
echo "starting big corperate labels"
for i in `seq 1 100`;
do
  sed "s/_SEDME_/${i}/g" pause-biglabels.yaml | kubectl -n pause apply -f -
done
ENDDATE=$(date +%s%3N)
annotate_grafana $STARTDATE $ENDDATE "biglabel service apply"
sleep $PAUSE

STARTDATE=$(date +%s%3N)
kubectl -n pause rollout restart deployment pause
kubectl -n pause rollout status deployment/pause --timeout=60s
ENDDATE=$(date +%s%3N)
annotate_grafana $STARTDATE $ENDDATE "rollout pods biglabel"
sleep $PAUSE
sleep $PAUSE

## Cleanup lab 
STARTDATE=$(date +%s%3N)
for i in `seq 1 100`;
do
  sed "s/_SEDME_/${i}/g" pause-biglabels.yaml | kubectl -n pause delete -f -
done

ENDDATE=$(date +%s%3N)
annotate_grafana $STARTDATE $ENDDATE "biglabel service delete"
## End Cleanup