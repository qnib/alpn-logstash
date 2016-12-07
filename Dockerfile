FROM qnib/alpn-jre8

ARG LOGSTASH_VER=2.4.0
ARG LOGSTASH_URL=https://download.elastic.co/logstash/logstash
RUN wget -qO - ${LOGSTASH_URL}/logstash-${LOGSTASH_VER}.tar.gz |tar xfz - -C /opt/ \
 && mv /opt/logstash-${LOGSTASH_VER} /opt/logstash \
 && echo
RUN echo \
 && /opt/logstash/bin/logstash-plugin install \
       logstash-codec-oldlogstashjson \
       logstash-input-elasticsearch \
       logstash-input-tcp \
       logstash-input-udp \
       logstash-input-syslog \
       logstash-filter-grok \
       logstash-filter-mutate \
       logstash-filter-zeromq \
       logstash-output-elasticsearch \
       logstash-output-kafka \
 && apk --no-cache add curl nmap
ADD etc/supervisord.d/logstash.ini /etc/supervisord.d/
ADD etc/consul.d/logstash.json \
    etc/consul.d/logstash_syslog.json \
    etc/consul.d/logstash_udp.json \
    /etc/consul.d/
ADD opt/qnib/logstash/bin/start.sh \
    /opt/qnib/logstash/bin/
ADD opt/qnib/logstash/etc/gelf.conf \
    opt/qnib/logstash/etc/
RUN echo "tail -f /var/log/supervisor/logstash.log" >> /root/.bash_history
