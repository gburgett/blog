FROM haproxy:latest

RUN apt-get update && \
    apt-get install --yes inotify-tools dnsmasq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
ADD haproxy.sh /

VOLUME /var/ssl
EXPOSE 80 443

ENTRYPOINT /haproxy.sh