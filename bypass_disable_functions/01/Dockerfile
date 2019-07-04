FROM php:5.6.11-apache

COPY src/shell.php /var/www/html/index.php
COPY src/shell.php /var/www/html/ant.php

COPY src/php.ini /usr/local/etc/php/php.ini

EXPOSE 80

RUN set -x \
  && chown -R www-data:www-data /var/www/html
