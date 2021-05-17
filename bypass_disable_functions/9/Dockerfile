FROM php:7.4-apache

COPY src/shell.php /var/www/html/index.php
COPY src/shell.php /var/www/html/ant.php

COPY src/php.ini /usr/local/etc/php/php.ini


COPY src/start.sh /start.sh

RUN set -x \
  && chmod +x /start.sh \
  && chown -R www-data:www-data /var/www/html

EXPOSE 80
ENTRYPOINT [ "/start.sh" ]