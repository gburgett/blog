FROM httpd:2

RUN apt-get update && apt-get install -y curl

# Install hugo
RUN curl -L -o /tmp/hugo.tar.gz https://github.com/spf13/hugo/releases/download/v0.16/hugo_0.16_linux-32bit.tgz
RUN tar xvf /tmp/hugo.tar.gz -C /tmp/
RUN mv /tmp/hugo /usr/bin/hugo

# copy config
COPY ./conf/ /usr/local/apache2/conf/

# copy source and generate result
COPY ./hugo/ /src/
RUN hugo -s /src/ --baseUrl="http://www.gordonburgett.net"
RUN rm -r /usr/local/apache2/htdocs && mv /src/public /usr/local/apache2/htdocs
