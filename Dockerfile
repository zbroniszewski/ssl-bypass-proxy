FROM nginx:1.25.2

ARG FQDN

# Use bash for build, fail when any command in a pipeline fails
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Remove existing nginx configuration
RUN rm -rf /etc/nginx/conf.d/*

# Add nginx configuration
COPY ./.docker/nginx/conf/conf.d/ /etc/nginx/templates/
RUN find /etc/nginx/templates/ -type f -print0 | xargs -0 -I {} mv {} {}.template

# Add entrypoint scripts
COPY ./.docker/nginx/conf/entrypoint.d/ /docker-entrypoint.d/
RUN chmod 500 /docker-entrypoint.d/*.sh

# Add SSL certificate / key
COPY ./.docker/nginx/conf/ssl/ /etc/ssl/
RUN chmod 400 /etc/ssl/{certs,private}/${FQDN}.pem
