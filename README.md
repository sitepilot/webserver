# Web Server (Openlitespeed with PHP7.4)

[![Actions Status](https://github.com/sitepilot/webserver/workflows/deploy/badge.svg)](https://github.com/sitepilot/webserver/actions)
[![](https://images.microbadger.com/badges/version/sitepilot/webserver.svg)](https://cloud.docker.com/u/sitepilot/repository/docker/sitepilot/webserver)
[![](https://images.microbadger.com/badges/image/sitepilot/webserver.svg)](https://cloud.docker.com/u/sitepilot/repository/docker/sitepilot/webserver)

## Installed software
* Openlitespeed 
* LSPHP 7.4
* Composer
* PHPunit
* WPCLI
  
## Configuration

### Images
* `sitepilot/webserver:latest` for production ready Docker image.

### Environment Variables
Use the environment variables below to change the web server and PHP settings.

#### Webserver

| Name | Description|
|------|------------|
|WEBSERVER_USER_ID|Run the web server and PHP with a specific user ID (to match the host), default: `1000`|
|WEBSERVER_USER_GID|Run the web server and PHP with a specific group ID (to match the host), default: `1000`|
|WEBSERVER_SERVER_NAME|Change the web server name, default: `webserver`|
|WEBSERVER_SSL_CERT|Change the default web server ssl certificate, default: `/sitepilot/conf/cert/default.crt`|
|WEBSERVER_SSL_KEY|Change the default web server ssl key, default: `/sitepilot/conf/cert/default.key`| 
|WEBSERVER_TRUSTED_IPS|Change the web server trusted IPS (when behind a proxy), default: `10.133.0.0/16T, 10.244.0.0/16T`|
|WEBSERVER_CACHE|Enable or disable the Litespeed cache, default: `off`|

#### PHP
| Name | Description|
|------|------------|
|PHP_TIMEZONE|Change the PHP timezone, default: `Europe\Amsterdam`|
|PHP_MEMORY_LIMIT|Change the PHP memory limit, default: `256M`|
|PHP_POST_MAX_SIZE|Change the PHP maximum post size, default `64M`|
|PHP_UPLOAD_MAX_FILESIZE|Change the PHP maximum upload filesize, default `32M`|
|PHP_DISPLAY_ERRORS|Display PHP (programming) errors, default: `on`|

#### SMTP
| Name | Description|
|------|------------|
|SMTP_DOMAIN|The address where the mail appears to come from for user authentication, default `mg.sitepilot.io`|
|SMTP_SERVER|The address of the SMTP server, default `smtp.eu.mailgun.org:587`|
|SMTP_AUTH_USER_FILE|Load SMTP user from a docker secrets file, default `/sitepilot/secrets/smtp_auth_user`|
|SMTP_AUTH_PASSWORD_FILE|Load SMTP password from a docker secrets file, default `/sitepilot/secrets/smtp_auth_password`|

#### WordPress
| Name | Description|
|------|------------|
|WP_INSTALL|Install WordPress (if not already installed), default `no`|

### Ports
Mount these ports to the host to get access to the web server:
* `80`: web server HTTP-port.
* `443`: web server HTTPS-port.

### Volumes
Mount these folders to the host to prevent data loss:
* `/var/www`: the (default) virtual host root for application files and logs.
  
### Cronjobs
The default cronjob is configured to run the WordPress cron every 15 minutes. Mount a crontab file to `/sitepilot/conf/crontabs/app` if you would like to use / configure your own cronjobs (this file will be loaded automatically when the container starts).