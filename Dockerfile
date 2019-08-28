FROM alpine:3.9
MAINTAINER Sitepilot <support@sitepilot.io>

LABEL org.label-schema.vendor="Sitepilot" \
      org.label-schema.name="webserver" \
      org.label-schema.description="Web server docker image with PHP and Nginx." \
      org.label-schema.url="https://sitepilot.io"

# Build arguments
ARG PHP_VER=7.2
ARG PHP_VER=$PHP_VER
ARG PHP_MEMORY_LIMIT=256M
ARG PHP_UPLOAD_MAX_FILESIZE=32M
ARG PHP_DISPLAY_ERRORS=on
ARG WEBSERVER_USER_NAME=sitepilot
ARG WEBSERVER_USER_ID=1000
ARG WEBSERVER_USER_GID=1000
ARG WEBSERVER_DOCROOT=/var/www/html
ARG WEBSERVER_SERVER_NAME=webserver
ARG WEBSERVER_SSL_CERT=/conf/cert/default.crt
ARG WEBSERVER_SSL_KEY=/conf/cert/default.key

# Environment variables
ENV PHP_VER=$PHP_VER
ENV PHP_MEMORY_LIMIT=$PHP_MEMORY_LIMIT
ENV PHP_UPLOAD_MAX_FILESIZE=$PHP_UPLOAD_MAX_FILESIZE
ENV PHP_POST_MAX_SIZE=$PHP_UPLOAD_MAX_FILESIZE
ENV PHP_DISPLAY_ERRORS=$PHP_DISPLAY_ERRORS
ENV WEBSERVER_USER_NAME=$WEBSERVER_USER_NAME
ENV WEBSERVER_USER_ID=$WEBSERVER_USER_ID
ENV WEBSERVER_USER_GID=$WEBSERVER_USER_GID
ENV WEBSERVER_SERVER_NAME=$WEBSERVER_SERVER_NAME
ENV WEBSERVER_SSL_CERT=$WEBSERVER_SSL_CERT
ENV WEBSERVER_SSL_KEY=$WEBSERVER_SSL_KEY
ENV WEBSERVER_DOCROOT=$WEBSERVER_DOCROOT

# PHP_INI_DIR to be symmetrical with official php docker image
ENV PHP_INI_DIR=/etc/php/$PHP_VER

# When using Composer, disable the warning about running commands as root/super user
ENV COMPOSER_ALLOW_SUPERUSER=1

# Persistent runtime dependencies
ARG DEPS="\
        nginx \
        nginx-mod-http-headers-more \
        php$PHP_VER \
        php$PHP_VER-phar \
        php$PHP_VER-bcmath \
        php$PHP_VER-calendar \
        php$PHP_VER-mbstring \
        php$PHP_VER-exif \
        php$PHP_VER-ftp \
        php$PHP_VER-openssl \
        php$PHP_VER-zip \
        php$PHP_VER-sysvsem \
        php$PHP_VER-sysvshm \
        php$PHP_VER-sysvmsg \
        php$PHP_VER-shmop \
        php$PHP_VER-sockets \
        php$PHP_VER-zlib \
        php$PHP_VER-bz2 \
        php$PHP_VER-curl \
        php$PHP_VER-simplexml \
        php$PHP_VER-xml \
        php$PHP_VER-opcache \
        php$PHP_VER-dom \
        php$PHP_VER-xmlreader \
        php$PHP_VER-xmlwriter \
        php$PHP_VER-tokenizer \
        php$PHP_VER-ctype \
        php$PHP_VER-session \
        php$PHP_VER-fileinfo \
        php$PHP_VER-iconv \
        php$PHP_VER-json \
        php$PHP_VER-posix \
        php$PHP_VER-fpm \
        php$PHP_VER-pdo_mysql \
        curl \
        ca-certificates \
        runit \
        nano \
        bash \
        perl \
        shadow \
        certbot \
        su-exec \
"

# PHP.earth Alpine repository for better developer experience
ADD https://repos.php.earth/alpine/phpearth.rsa.pub /etc/apk/keys/phpearth.rsa.pub

# Install packages
RUN set -x \
    && echo "https://repos.php.earth/alpine/v3.9" >> /etc/apk/repositories \
    && apk add --no-cache $DEPS \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

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
RUN chmod -R +x /sbin/*
RUN chmod -R +x /etc/service/*
RUN chmod u+s /sbin/su-exec

# Cleanup
RUN rm -rf /var/www/localhost

# Expose ports
EXPOSE 80
EXPOSE 443

# Set workdir
WORKDIR /var/www/html

# Set volumes
VOLUME ["/var/www/html", "/var/www/log"]

# Setup user
RUN addgroup --gid "$WEBSERVER_USER_GID" "$WEBSERVER_USER_NAME" \
    && adduser \
        --disabled-password \
        --gecos "" \
        --home "/var/www/html" \
        --ingroup "$WEBSERVER_USER_NAME" \
        --no-create-home \
        --uid "$WEBSERVER_USER_ID" \
        "$WEBSERVER_USER_NAME"

USER $WEBSERVER_USER_NAME

# Set entrypoint
ENTRYPOINT ["su-exec", "root", "/sbin/entrypoint"]

# Start services
CMD ["su-exec", "root", "/sbin/runit-wrapper"]