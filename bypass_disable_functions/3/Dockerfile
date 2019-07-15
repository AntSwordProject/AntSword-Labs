FROM antswordproject/antsword-labs:bypass_disable_functions_1

COPY src/php.ini /usr/local/etc/php/php.ini

RUN set -x \
  && a2enmod rewrite cgi \
  && a2ensite 000-default
