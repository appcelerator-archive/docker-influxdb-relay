#!/bin/bash

CONFIG_FILE="/etc/relay.toml"
CONFIG_OVERRIDE_FILE="/etc/base-config/influxdb-relay/relay.toml"
CONFIG_EXTRA_DIR="/etc/extra-config/influxdb-relay/"

# set env variables for configuration template

if [[ -n "$CONFIG_ARCHIVE_URL" ]]; then
  echo "INFO - Download configuration archive file $CONFIG_ARCHIVE_URL..."
  curl -L "$CONFIG_ARCHIVE_URL" -o /tmp/config.tgz
  if [[ $? -eq 0 ]]; then
    tmpd=$(mktemp -d)
    gunzip -c /tmp/config.tgz | tar xf - -C $tmpd
    echo "INFO - Overriding configuration file:"
    find $tmpd/*/base-config/influxdb-relay 2>/dev/null
    echo "INFO - Extra configuration file:"
    find $tmpd/*/extra-config/influxdb-relay 2>/dev/null
    mv $tmpd/*/extra-config $tmpd/*/base-config /etc/ 2>/dev/null
    rm -rf /tmp/config.tgz "$tmpd"
  else
    echo "WARN - download failed, ignore"
  fi
fi

if [ -f "${CONFIG_OVERRIDE_FILE}" ]; then
  echo "INFO - Override InfluxDB configuration file"
  cp "${CONFIG_OVERRIDE_FILE}" "${CONFIG_FILE}"
else
    if [ -f ${CONFIG_FILE}.tpl ]; then
        envtpl ${CONFIG_FILE}.tpl
        if [ $? -ne 0 ]; then
            echo "ERROR - unable to generate $CONFIG_FILE"
            exit 1
        fi
    else
        echo "INFO - no ${CONFIG_FILE}.tpl found, will look for ${CONFIG_FILE}..."
    fi
fi
if [ ! -f "${CONFIG_FILE}" ]; then
    echo "ERROR - can't find ${CONFIG_FILE}"
    exit 1
fi

CMD="/bin/influxdb-relay"
CMDARGS="-config=${CONFIG_FILE}"
exec "$CMD" $CMDARGS
