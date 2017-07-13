FROM httpd:2

# copy config
COPY ./apache2/conf/ /usr/local/apache2/conf/

# copy source and generate result
COPY ./public/ /usr/local/apache2/htdocs
