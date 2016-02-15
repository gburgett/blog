FROM centos:centos7

# Enable EPEL for Node.js
RUN yum install -y epel-release
# Install Node.js and npm
RUN yum install -y nodejs npm

# Install hugo
RUN curl -L -o /tmp/hugo.tar.gz https://github.com/spf13/hugo/releases/download/v0.14/hugo_0.14_linux_386.tar.gz
RUN tar xvf /tmp/hugo.tar.gz -C /tmp/
RUN mv /tmp/hugo_0.14_linux_386/hugo_0.14_linux_386 /usr/bin/hugo

COPY package.json /src/package.json
RUN cd /src; npm install

EXPOSE 8080

CMD ["node", "/src/node/server.js", "/src/public", "8080"]

COPY ./ /src/
RUN hugo -s /src/ --baseUrl="http://www.gordonburgett.net"