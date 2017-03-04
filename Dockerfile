FROM amazeeio/centos:7

MAINTAINER amazee.io

# Install required repos, update, and then install PHP-FPM
RUN yum install -y epel-release \ 
        http://rpms.remirepo.net/enterprise/remi-release-7.rpm  \
        yum-utils && \
    yum-config-manager --enable remi-php70 && \
    yum install -y \
        php-bcmath \
        php-cli \
        php-fpm \
        php-mysqlnd \
        php-mssql \
        php-xml \
        php-pgsql \
        php-gd \
        php-mcrypt \
        php-ldap \
        php-imap \
        php-soap \
        php-tidy \
        php-mbstring \
        php-opcache \
        php-pdo \
        php-pecl-apcu \
        php-pecl-apcu-bc \
        php-pecl-geoip \
        php-pecl-igbinary \
        php-pecl-imagick \
        php-pecl-redis \
        unzip && \
    yum --enablerepo=epel install -y fcgi && \
    yum clean all 

COPY container-entrypoint /usr/sbin/container-entrypoint

COPY php-fpm.conf php.ini /etc/
COPY php/www.conf /etc/php-fpm.d/www.conf

# Setup the Composer installer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer &&  \
    curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig && \
    php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"

RUN COMPOSER_ALLOW_SUPERUSER=1 php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer && rm -rf /tmp/composer-setup.php

RUN mkdir -p /app && \
    fix-permissions /run/php-fpm && \
    fix-permissions /app && \
    fix-permissions /var/lib/php/session/

EXPOSE 9000

ENTRYPOINT ["container-entrypoint"]

# Run PHP-FPM on container start.
CMD ["/usr/sbin/php-fpm", "-F"]