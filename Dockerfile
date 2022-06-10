FROM php:7.4-fpm-alpine3.14

MAINTAINER Patric Eckhart <mail@patriceckhart.com>

ENV COMPOSER_VERSION 2.3.5
ENV PERSISTENT_RESOURCES_FALLBACK_BASE_URI 0
ENV HOME /data/neos
ENV FLOW_PATH_TEMPORARY_BASE /data/neos/Data/Temporary
ARG PHP_XDEBUG_VERSION="3.1.4"

RUN set -x \
	&& apk update \
	&& apk add bash \
	&& apk add nano gettext git nginx tar curl postfix mariadb-client optipng freetype libjpeg-turbo-utils icu-dev vips-dev vips-tools openssh pwgen build-base && apk add --virtual libtool freetype-dev libpng-dev libjpeg-turbo-dev yaml-dev libssh2-dev \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install \
		gd \
		pdo \
		pdo_mysql \
		opcache \
		intl \
		exif \
		tokenizer \
		json \
	&& apk add --no-cache --virtual .deps imagemagick imagemagick-libs imagemagick-dev autoconf \
	&& deluser www-data \
	&& delgroup cdrw \
	&& addgroup -g 80 www-data \
	&& adduser -u 80 -G www-data -s /bin/bash -D www-data -h /data \
	&& rm -Rf /home/www-data \
	&& sed -i -e "s#listen = 9000#listen = /var/run/php-fpm.sock#" /usr/local/etc/php-fpm.d/zz-docker.conf \
	&& echo "clear_env = no" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
	&& echo "listen.owner = www-data" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
	&& echo "listen.group = www-data" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
	&& echo "listen.mode = 0660" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
	&& sed -i -e "s#listen = 127.0.0.1:9000#listen = /var/run/php-fpm.sock#" /usr/local/etc/php-fpm.d/www.conf \
	&& chown 80:80 -R /var/lib/nginx \
	&& apk add --no-cache redis \
	&& pecl install redis && docker-php-ext-enable redis \
	&& docker-php-ext-install bcmath && docker-php-ext-enable bcmath \
	&& docker-php-ext-install sysvsem && docker-php-ext-enable sysvsem \
	&& apk add imap-dev krb5-dev \
	&& docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
	&& docker-php-ext-install imap \
	&& docker-php-ext-enable imap \
	&& apk add \
	       libzip-dev \
	       zip \
	&& docker-php-ext-install zip \
	&& pecl install imagick-beta && docker-php-ext-enable --ini-name 20-imagick.ini imagick \
	&& pecl install vips && echo "extension=vips.so" > /usr/local/etc/php/conf.d/ext-vips.ini && docker-php-ext-enable --ini-name ext-vips.ini vips \
	&& cd /tmp \
	&& pecl install ssh2-1.3.1 && docker-php-ext-enable ssh2 && pecl install xdebug-${PHP_XDEBUG_VERSION} && docker-php-ext-enable xdebug \
	&& echo "xdebug.remote_enable=0" >> $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
	&& echo "xdebug.remote_connect_back=1" >> $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
	&& echo "xdebug.max_nesting_level=512" >> $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
	&& echo "xdebug.idekey=\"PHPSTORM\"" >> $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
	&& echo "xdebug.remote_host=172.17.0.1" >> $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
	&& pecl install yaml && echo "extension=yaml.so" > /usr/local/etc/php/conf.d/ext-yaml.ini && docker-php-ext-enable --ini-name ext-yaml.ini yaml \
	&& curl -o /tmp/composer-setup.php https://getcomposer.org/installer && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --version=${COMPOSER_VERSION} && rm -rf /tmp/composer-setup.php \
	&& echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config \
	&& rm -rf /var/cache/apk/* \
	&& apk add tzdata \
	&& apk del tzdata \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /run/nginx

EXPOSE 80 443 22

WORKDIR /data

COPY /root-files/ /root-files/
RUN chmod -R 755 /root-files

ENTRYPOINT ["/root-files/entrypoint.sh"]