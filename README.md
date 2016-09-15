## Gordon Burgett's personal blog

This repo contains my personal blog.  It's mostly a static web site, but it's hosted by nodejs using express.

All the static files are generated by Hugo, inside a docker container.  The docker container is uploaded to dockerhub at "gordonburgett/blog"

The web server runs the docker container with ports 8080 and 8081.  HAProxy is used as a reverse proxy to terminate the SSL connection and forward to these ports.
