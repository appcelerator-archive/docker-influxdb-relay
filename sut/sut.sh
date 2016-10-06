#!/bin/bash

PROXY_HOST=influxdb-proxy
PROXY_PORT=8086
BACKEND_HOSTS="influxdb-backend-a influxdb-backend-b"
BACKEND_PORT=8086

echo -n "wait for influxdb proxy to be available...     "
r=""
i=0
while [[ -z "$r" ]]; do
  r=$(dig +short $PROXY_HOST)
  ((i++))
  if [[ $i -gt 10 ]]; then
    echo "failed"
    dig +short $PROXY_HOST
    exit 1
  fi
  sleep 1
done
echo "[OK]"

sleep 3

d="$(date +%s)000000000"
echo -n "push data to influxdb...                       "
curl -s -i -XPOST "http://${PROXY_HOST}:${PROXY_PORT}/write?db=mydb" --data-binary "cpu_load_short,host=server01,region=us-west value=0.64 $d" | grep -w 204
if [[ ${PIPESTATUS[1]} -ne 0 ]]; then
  echo "[failed]"
  exit 1
fi
echo "[OK]"

echo -n "read data from influxdb proxy...               "
r=$(curl -s -GET "http://${PROXY_HOST}:${PROXY_PORT}/query?pretty=true" --data-urlencode "db=mydb" --data-urlencode "q=SELECT \"value\" FROM \"cpu_load_short\" WHERE \"region\"='us-west'")
if [[ $? -ne 0 ]]; then
  curl -s -GET "http://${PROXY_HOST}:${PROXY_PORT}/query?pretty=true" --data-urlencode "db=mydb" --data-urlencode "q=SELECT \"value\" FROM \"cpu_load_short\" WHERE \"region\"='us-west'"
  echo "[failed]"
  exit 1
fi
n=$(echo $r | jq -r '.results[0].series[0]')
if [[ "$n" = "null" ]]; then
  echo "[failed] ($n)"
  exit 1
fi
echo "[OK]"

echo -n "read data from influxdb backends...            "
for b in $BACKEND_HOSTS; do
  r=$(curl -s -GET "http://${b}:${BACKEND_PORT}/query?pretty=true" --data-urlencode "db=mydb" --data-urlencode "q=SELECT \"value\" FROM \"cpu_load_short\" WHERE \"region\"='us-west'")
  if [[ $? -ne 0 ]]; then
    echo "[failed]"
    curl -s -GET "http://${b}:${BACKEND_PORT}/query?pretty=true" --data-urlencode "db=mydb" --data-urlencode "q=SELECT \"value\" FROM \"cpu_load_short\" WHERE \"region\"='us-west'"
    exit 1
  fi
  n=$(echo $r | jq -r '.results[0].series[0]')
  if [[ "$n" = "null" ]]; then
    echo "[failed] ($n)"
    exit 1
  fi
done
echo "[OK]"

echo "all test passed successfully"
