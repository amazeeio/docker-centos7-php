FROM centos:centos7

MAINTAINER "Dylan Lindgren" <dylan.lindgren@gmail.com>

# Install required repos, update, and then install PHP-FPM
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \ 
        http://rpms.remirepo.net/enterprise/remi-release-7.rpm  \
        yum-utils && \
    yum-config-manager --enable remi-php70 && \
    yum install -y \
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
        php-mbstring \
        php-pdo

# Configure and secure PHP
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php.ini && \
    sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php.ini && \
    sed -i -e "s/daemonize\s*=\s*yes/daemonize = no/g" /etc/php-fpm.conf && \
    sed -i "s/error_log = .*/error_log = \/proc\/self\/fd\/2/" /etc/php-fpm.conf && \
    sed -i '/^listen = /clisten = [::]:9000' /etc/php-fpm.d/www.conf && \
    sed -i '/^listen.allowed_clients/c;listen.allowed_clients =' /etc/php-fpm.d/www.conf && \
    sed -i "s/;access.log = .*/access.log = \/proc\/self\/fd\/2/" /etc/php-fpm.d/www.conf && \
    sed -i '/^;catch_workers_output/ccatch_workers_output = yes' /etc/php-fpm.d/www.conf && \
    sed -i "s/php_admin_flag\[log_errors\] = .*/;php_admin_flag[log_errors] =/" /etc/php-fpm.d/www.conf && \
    sed -i "s/php_admin_value\[error_log\] =.*/;php_admin_value[error_log] = /" /etc/php-fpm.d/www.conf 

ADD fix-permissions /bin/fix-permissions

RUN mkdir -p /app && \
    fix-permissions /run/php-fpm  && \
    fix-permissions /app 

# PORTS
# Port 9000 is how Nginx will communicate with PHP-FPM.
EXPOSE 9000

# Run PHP-FPM on container start.
CMD ["/usr/sbin/php-fpm", "-F"]