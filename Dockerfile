FROM centos:centos7

# Enable EPEL for Node.js
RUN yum install -y epel-release
# Install Node.js and npm
RUN yum install -y nodejs npm

COPY package.json /src/package.json
RUN cd /src; npm install

EXPOSE 8080 8081

CMD ["node", "/src/server.js", "/www", "8080", "8081"]

COPY ./node/ /src
COPY ./public /www