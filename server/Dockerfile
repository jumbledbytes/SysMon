# Use dockers offical node as the base image.
# TODO: play with using alpine instead for reduced image size.
FROM node:6
MAINTAINER Jeff Batis

# Inform docker of the port it uses.
EXPOSE 7588

# For compatibility with "atomic" launcher
LABEL RUN /usr/bin/docker run -ti -p 7588:7588 systemmonitor

# Run installation scripts to build the app.
# First update npm
RUN npm install npm

# Copy project files to the appropriate locations.
COPY certs /certs
# Specify that certificates is accessible from other containers.
VOLUME /certs
COPY systemmonitor/package.json /systemmonitor/

# Install the node app
WORKDIR /systemmonitor
RUN npm install

WORKDIR /
COPY systemmonitor /systemmonitor/

WORKDIR /systemmonitor

# Default command to run is "npm" and default arguments are "start systemmonitor"
CMD ["start"]
ENTRYPOINT ["npm"]
