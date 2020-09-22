FROM php:7.4-apache

LABEL mantainer "TikiWiki <tikiwiki-devel@lists.sourceforge.net>"
LABEL PHP_VERSION=7.4.10

RUN a2enmod rewrite expires \
    && apt-get update \
    && apt-get install -y libldb-dev libldap2-dev libmemcached-dev libpng-dev libjpeg-dev libzip-dev libicu-dev libfreetype6-dev libonig-dev unzip \
    && ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
    && ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so \
    && ln -s /usr/bin/pkg-config /usr/local/bin/icu-config \
    && docker-php-ext-configure gd --with-freetype --with-jpeg=/usr \
    && docker-php-ext-install calendar gd intl ldap mysqli mbstring pdo_mysql zip \
    && printf "yes\n" | pecl install xdebug \
    && printf "no\n"  | pecl install apcu-beta \
    && printf "no\n"  | pecl install memcached \
    && echo 'extension=apcu.so' > /usr/local/etc/php/conf.d/pecl-apcu.ini \
    && echo 'extension=memcached.so' > /usr/local/etc/php/conf.d/pecl-memcached.ini \
    && echo "extension=ldap.so" > /usr/local/etc/php/conf.d/docker-php-ext-ldap.ini \
    && curl -s -o installer.php https://getcomposer.org/installer \
    && php installer.php --install-dir=/usr/local/bin/ --filename=composer \
    && { \
        COMPOSER_HOME=/usr/local/share/composer \
        COMPOSER_BIN_DIR=/usr/local/bin \
        COMPOSER_CACHE_DIR="/tmp/root/composer" \
        composer global require psy/psysh --prefer-stable; \
    } \
    && rm installer.php \
    && rm /usr/local/bin/icu-config \
    && apt-get purge -y libldb-dev libldap2-dev libmemcached-dev libpng-dev libjpeg-dev libzip-dev libicu-dev libfreetype6-dev libonig-dev \
    && docker-php-source delete \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && { \
        echo "file_uploads = On"; \
        echo "upload_max_filesize = 2048M"; \
        echo "post_max_size = 2048M"; \
        echo "max_file_uploads = 20"; \
    } > /usr/local/etc/php/conf.d/docker-uploads.ini

COPY root/ /
EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
