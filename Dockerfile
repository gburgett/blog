FROM httpd:2

RUN apt-get update && apt-get install -y curl

# Install hugo
RUN curl -L -o /tmp/hugo.tar.gz https://github.com/spf13/hugo/releases/download/v0.15/hugo_0.15_linux_386.tar.gz
RUN tar xvf /tmp/hugo.tar.gz -C /tmp/
RUN mv /tmp/hugo_0.15_linux_386/hugo_0.15_linux_386 /usr/bin/hugo

EXPOSE 80

COPY ./ /src/
RUN hugo -s /src/ --baseUrl="http://www.gordonburgett.net"
RUN mv ./public/* /usr/local/apache2/htdocs/