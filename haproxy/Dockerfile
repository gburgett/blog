FROM haproxy:latest

RUN apt-get update

COPY haproxy.cfg /etc/haproxy/haproxy.cfg

VOLUME /var/ssl
EXPOSE 80 443