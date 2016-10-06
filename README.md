# InfluxDB relay

https://github.com/influxdata/influxdb-relay

## Run the container

    docker -e BACKEND_influxdb_a=influxdb-a:8086 -e BACKEND_influxdb_b=influxdb-b:8086 \
           -e RELAY_influxdb_a=influxdb-relay-a:9096 -e RELAY_influxdb_b=influxdb-relay-b:9096 \
           run appcelerator/haproxy-proxy

## Configuration

Variable | Description | Default value | Sample value 
-------- | ----------- | ------------- | ------------
HTTP_BIND_ADDR | bind address for the HTTP listener | :9096 |
UDP_BIND_ADDR | bind address for the UDP listener | :9096 |
HTTP_BACKEND_xx | host:port of an influxDB backend, http protocol | | influxdb-backend:8086 
UDP_BACKEND_xx | host:port of an influxDB backend, udp protocol | | influxdb-backend:8086 
UDP_MTU | UDP MTU | 512 | 1024
