FROM php:5.6.11-apache

COPY src/shell.php /var/www/html/index.php
COPY src/shell.php /var/www/html/ant.php

COPY src/php.ini /usr/local/etc/php/php.ini

RUN set -x \
  && docker-php-ext-install mysql mysqli pdo_mysql \
  && docker-php-ext-enable mysql mysqli pdo_mysql \
  && chown -R www-data:www-data /var/www/html
