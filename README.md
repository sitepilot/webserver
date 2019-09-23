# Web Server (Openlitespeed with PHP7.2)

[![Actions Status](https://github.com/sitepilot/webserver/workflows/deploy/badge.svg)](https://github.com/sitepilot/webserver/actions)
[![](https://images.microbadger.com/badges/version/sitepilot/webserver.svg)](https://cloud.docker.com/u/sitepilot/repository/docker/sitepilot/webserver)
[![](https://images.microbadger.com/badges/image/sitepilot/webserver.svg)](https://cloud.docker.com/u/sitepilot/repository/docker/sitepilot/webserver)

## Installed software
* Openlitespeed 
* LSPHP 7.2
* Composer
* PHPunit
* WPCLI
* Certbot (Let's Encrypt)

## Configuration

### Images
* `sitepilot/webserver:latest` for production ready Docker image.
* `sitepilot/webserver:dev-latest` for development ready Docker image (with Xdebug installed).

### Environment variables
Use the environment variables below to change the web server and PHP settings.

| Name | Description|
|------|------------|
|WEBSERVER_USER_ID|Run the web server and PHP with a specific user ID (to match the host), default: `1000`|
|WEBSERVER_USER_GID|Run the web server and PHP with a specific group ID (to match the host), default: `1000`|
|WEBSERVER_DOCROOT|Change the web server document root, default: `/var/www/html`|
|WEBSERVER_SERVER_NAME|Change the web server name, default: `webserver`|
|WEBSERVER_SSL_CERT|Change the default web server ssl certificate, default: `/sitepilot/conf/cert/default.crt`|
|WEBSERVER_SSL_KEY|Change the default web server ssl key, default: `/sitepilot/conf/cert/default.key`| 
|PHP_MEMORY_LIMIT|Change the PHP memory limit, default: `256M`|
|PHP_UPLOAD_MAX_FILESIZE|Change the PHP maximum upload filesize, default `32M`|
|PHP_DISPLAY_ERRORS|Display PHP (programming) errors, default: `on`|

### Ports
Mount these ports to the host to get access to the web server:
* `80`: web server HTTP-port.
* `443`: web server HTTPS-port.

### Volumes
Mount these folders to the host to prevent data loss:
* `/var/www/html`: the (default) document root for your application files.
* `/etc/letsencrypt`: requested Let's Encrypt certificates will be stored here.

### Cronjobs
The default cronjob is configured to run the WordPress cron every minute. Mount a crontab file to `/sitepilot/conf/crontabs/app` if you would like to use / configure your own cronjobs (this file will be loaded automatically when the container starts).