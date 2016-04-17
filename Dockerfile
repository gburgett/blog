FROM httpd:2

# Install hugo
RUN curl -L -o /tmp/hugo.tar.gz https://github.com/spf13/hugo/releases/download/v0.14/hugo_0.14_linux_386.tar.gz
RUN tar xvf /tmp/hugo.tar.gz -C /tmp/
RUN mv /tmp/hugo_0.14_linux_386/hugo_0.14_linux_386 /usr/bin/hugo

EXPOSE 80

COPY ./ /src/
RUN hugo -s /src/ --baseUrl="http://www.gordonburgett.net"
RUN mv ./public/* /usr/local/apache2/htdocs/