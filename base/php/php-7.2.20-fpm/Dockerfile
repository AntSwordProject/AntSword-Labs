FROM php:7.2.20-fpm

COPY src/shell.php /var/www/html/index.php
COPY src/shell.php /var/www/html/ant.php

COPY src/php.ini /usr/local/etc/php/php.ini

RUN set -x \
  && docker-php-ext-install mysqli pdo_mysql \
  && docker-php-ext-enable mysqli pdo_mysql \
  && chown -R www-data:www-data /var/www/html

EXPOSE 9000