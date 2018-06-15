# InfluxDB relay

https://github.com/influxdata/influxdb-relay

based on https://github.com/appcelerator/docker-influxdb-relay

## Run the container

    docker -e HTTP_BACKEND_influxdb_a=influxdb-a:8086 -e HTTP_BACKEND_influxdb_b=influxdb-b:8086 \
           run appcelerator/haproxy-relay

## Configuration

Variable | Description | Default value | Sample value 
-------- | ----------- | ------------- | ------------
HTTP_BIND_ADDR | bind address for the HTTP listener | :9096 |
UDP_BIND_ADDR | bind address for the UDP listener | :9096 |
HTTP_BACKEND_xx | host:port of an influxDB backend, http protocol | | influxdb-backend:8086 
UDP_BACKEND_xx | host:port of an influxDB backend, udp protocol | | influxdb-backend:8086 
UDP_MTU | UDP MTU | 512 | 1024
