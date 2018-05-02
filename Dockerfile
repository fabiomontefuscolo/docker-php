FROM php:7-apache
MAINTAINER Hacklab <contato@hacklab.com.br>

RUN a2enmod rewrite expires \
    && apt-get update \
    && apt-get install -y libldb-dev libldap2-dev libpng-dev libjpeg-dev unzip \
    && ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
    && ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install calendar gd ldap mysqli mbstring pdo_mysql zip \
    && printf "yes\n" | pecl install xdebug \
    && printf "no\n"  | pecl install apcu-beta \
    && echo 'extension=apcu.so' > /usr/local/etc/php/conf.d/pecl-apcu.ini \
    && echo "extension=ldap.so" > /usr/local/etc/php/conf.d/docker-php-ext-ldap.ini \
    && curl -s -o installer.php https://getcomposer.org/installer \
    && php installer.php --install-dir=/usr/local/bin/ --filename=composer \
    && rm installer.php \
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
