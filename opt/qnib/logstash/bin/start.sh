#!/usr/local/bin/dumb-init /bin/bash

source /opt/qnib/consul/etc/bash_functions.sh
wait_for_srv consul-http

mkdir -p /etc/logstash/conf.d

if [ $(find /etc/logstash/conf.d/ -name \*.conf|wc -l) -eq 0 ];then
    echo "## Logstash/conf.d empty. Copying default config..."
    echo "cp /opt/qnib/logstash/etc/*.conf /etc/logstash/conf.d/"
    cp /opt/qnib/logstash/etc/*.conf /etc/logstash/conf.d/
fi

### check inputs to remove checks
CONSUL_RELOAD=0
if [ $(grep -A3 "syslog {"  /etc/logstash/conf.d/*.conf |grep -c 5514) -eq 0 ];then
    rm -f /etc/consul.d/logstash_syslog.json
    CONSUL_RELOAD=1
fi
if [ $(grep -A3 "udp {"  /etc/logstash/conf.d/*.conf |grep -c 55514) -eq 0 ];then
    rm -f /etc/consul.d/logstash_udp.json
    CONSUL_RELOAD=1
fi
if [ ${CONSUL_RELOAD} -eq 1 ];then
    consul reload
fi


/opt/logstash/bin/logstash agent -f /etc/logstash/conf.d/
