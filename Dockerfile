FROM php:5.6-apache
MAINTAINER Fabio Montefuscolo <fabio.montefuscolo@gmail.com>

RUN a2enmod rewrite expires ssl \
    && apt-get update && apt-get install -y libpng12-dev libjpeg-dev libmemcached-dev libmcrypt-dev unzip libldb-dev libldap2-dev\
    && ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
    && ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install calendar gd mysqli opcache zip mbstring mcrypt \
    && printf "yes\n" | pecl install memcache-3.0.8 \
    && printf "yes\n" | pecl install memcached-2.2.0 \
    && printf "yes\n" | pecl install xdebug \
    && echo 'extension=memcache.so' > /usr/local/etc/php/conf.d/pecl-memcache.ini \
    && echo 'extension=memcached.so' > /usr/local/etc/php/conf.d/pecl-memcached.ini \
    && curl -s -o installer.php https://getcomposer.org/installer \
    && php installer.php --install-dir=/usr/local/bin/ --filename=composer \
    && rm installer.php \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

COPY root/ /

EXPOSE 80 443
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
