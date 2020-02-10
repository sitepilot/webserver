FROM ubuntu:18.04
MAINTAINER Sitepilot <support@sitepilot.io>

LABEL org.label-schema.vendor="Sitepilot" \
    org.label-schema.name="webserver" \
    org.label-schema.description="Web server docker image with PHP and Openlitespeed." \
    org.label-schema.url="https://sitepilot.io"

# Build arguments
ARG PHP_VER="74"
ARG PHP_VER=$PHP_VER
ARG PHP_MEMORY_LIMIT=256M
ARG PHP_UPLOAD_MAX_FILESIZE=32M
ARG PHP_DISPLAY_ERRORS=on
ARG PHP_TIMEZONE="Europe/Amsterdam"

ARG SMTP_DOMAIN="app.sitepilot.io"
ARG SMTP_SERVER="smtp.eu.mailgun.org:587"
ARG SMTP_AUTH_USER="postmaster@mg.sitepilot.io"
ARG SMTP_AUTH_PASSWORD=""

ARG WEBSERVER_USER_ID=1000
ARG WEBSERVER_USER_GID=1000
ARG WEBSERVER_USER_NAME=sitepilot
ARG WEBSERVER_DOCROOT=/var/www/html
ARG WEBSERVER_SERVER_NAME=webserver
ARG WEBSERVER_SSL_CERT=/sitepilot/conf/cert/default.crt
ARG WEBSERVER_SSL_KEY=/sitepilot/conf/cert/default.key

ARG DEBIAN_FRONTEND=noninteractive

# Environment variables
ENV PHP_VER=$PHP_VER
ENV PHP_MEMORY_LIMIT=$PHP_MEMORY_LIMIT
ENV PHP_UPLOAD_MAX_FILESIZE=$PHP_UPLOAD_MAX_FILESIZE
ENV PHP_POST_MAX_SIZE=$PHP_UPLOAD_MAX_FILESIZE
ENV PHP_DISPLAY_ERRORS=$PHP_DISPLAY_ERRORS
ENV PHP_TIMEZONE=$PHP_TIMEZONE
ENV PHP_LSAPI_CHILDREN=35

ARG SMTP_DOMAIN=$SMTP_DOMAIN
ARG SMTP_SERVER=$SMTP_SERVER
ARG SMTP_AUTH_USER=$SMTP_AUTH_USER
ARG SMTP_AUTH_PASSWORD=$SMTP_AUTH_PASSWORD

ENV WEBSERVER_USER_NAME=$WEBSERVER_USER_NAME
ENV WEBSERVER_USER_ID=$WEBSERVER_USER_ID
ENV WEBSERVER_USER_GID=$WEBSERVER_USER_GID
ENV WEBSERVER_SERVER_NAME=$WEBSERVER_SERVER_NAME
ENV WEBSERVER_SSL_CERT=$WEBSERVER_SSL_CERT
ENV WEBSERVER_SSL_KEY=$WEBSERVER_SSL_KEY
ENV WEBSERVER_DOCROOT=$WEBSERVER_DOCROOT

# When using Composer, disable the warning about running commands as root/super user
ENV COMPOSER_ALLOW_SUPERUSER=1

# Enable openlitespeed repository
RUN apt-get update \
    && apt-get install -y wget \
    && wget -O - http://rpms.litespeedtech.com/debian/enable_lst_debain_repo.sh | bash

# Persistent runtime dependencies
ARG DEPS="\
    openlitespeed \
    lsphp$PHP_VER \
    lsphp$PHP_VER-mysql \
    lsphp$PHP_VER-imap \
    lsphp$PHP_VER-curl \
    lsphp$PHP_VER-common \
    lsphp$PHP_VER-json \
    lsphp$PHP_VER-redis \
    curl \
    runit \
    nano \
    perl \
    cron \
    ssmtp \
    less \
    sudo \
    "

# Install packages
RUN set -e \
    && apt-get update \
    && apt-get install -y $DEPS \
    && ln -s /usr/local/lsws/lsphp$PHP_VER/bin/php /usr/local/bin/php

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && mv composer.phar /usr/local/bin/composer \
    && php -r "unlink('composer-setup.php');"

# Install WPCLi
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

# Install PHPunit
RUN wget https://phar.phpunit.de/phpunit.phar \
    && chmod +x phpunit.phar \
    && mv phpunit.phar /usr/local/bin/phpunit

# Add configuration files
COPY tags /
RUN chmod -R +x /sitepilot/bin/*
RUN chmod -R +x /etc/service/*

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Setup user
RUN addgroup --gid "$WEBSERVER_USER_GID" "$WEBSERVER_USER_NAME" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home "/var/www/html" \
    --ingroup "$WEBSERVER_USER_NAME" \
    --no-create-home \
    --uid "$WEBSERVER_USER_ID" \
    "$WEBSERVER_USER_NAME" \
    && usermod -aG sudo $WEBSERVER_USER_NAME \
    && echo "${WEBSERVER_USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Expose ports
EXPOSE 80
EXPOSE 443

# Set workdir
WORKDIR /var/www/html

# Set user
USER $WEBSERVER_USER_NAME

# Set volumes
VOLUME ["/var/www"]

# Set entrypoint
ENTRYPOINT ["sudo", "-E", "/sitepilot/bin/entrypoint"]

# Start services
CMD ["sudo", "-E", "/sitepilot/bin/runit-wrapper"]
