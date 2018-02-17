FROM debian:stretch

# Credits
# Project: https://github.com/wyveo/nginx-php-fpm
# Author: Colin Wilson
# License: https://raw.githubusercontent.com/wyveo/nginx-php-fpm/master/LICENSE

MAINTAINER Thilina Perera "thilina@thilina.lk"

ENV DEBIAN_FRONTEND noninteractive
ENV NGINX_VERSION 1.13.7-1~stretch
ENV php_conf /etc/php/7.2/fpm/php.ini
ENV fpm_conf /etc/php/7.2/fpm/pool.d/www.conf
ENV nginx_conf /etc/nginx/nginx.conf

RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -q -y gnupg2 dirmngr wget apt-transport-https lsb-release ca-certificates \
    && apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
    && echo "deb http://nginx.org/packages/mainline/debian/ stretch nginx" >> /etc/apt/sources.list \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -q -y \
            apt-utils \
            curl \
            nano \
            zip \
            unzip \
            python-pip \
            python-setuptools \
            git \
            nginx=${NGINX_VERSION} \
            php7.2-fpm \
            php7.2-cli \
            php7.2-dev \
            php7.2-common \
            php7.2-json \
            php7.2-opcache \
            php7.2-readline \
            php7.2-mbstring \
            php7.2-curl \
            php7.2-memcached \
            php7.2-imagick \
            php7.2-mysql \
            php7.2-zip \
            php7.2-pgsql \
            php7.2-intl \
            php7.2-xml \
            php7.2-redis \
    && pip install wheel \
    && pip install supervisor supervisor-stdout \
    && echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d \
    && rm -rf /etc/nginx/conf.d/default.conf

# Override PHP's default config
ADD ./configs/php.ini /etc/php/7.2/fpm/php.ini

# Override NGiNX's default config
ADD ./configs/nginx.conf /etc/nginx/nginx.conf
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" ${php_conf} \
    && sed -i -e "s/memory_limit\s*=\s*.*/memory_limit = 256M/g" ${php_conf} \
    && sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" ${php_conf} \
    && sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" ${php_conf} \
    && sed -i -e "s/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/g" ${php_conf} \
    && sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.2/fpm/php-fpm.conf \
    && sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" ${fpm_conf} \
    && sed -i -e "s/pm.max_children = 5/pm.max_children = 4/g" ${fpm_conf} \
    && sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" ${fpm_conf} \
    && sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" ${fpm_conf} \
    && sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" ${fpm_conf} \
    && sed -i -e "s/pm.max_requests = 500/pm.max_requests = 200/g" ${fpm_conf} \
    && sed -i -e "s/www-data/nginx/g" ${fpm_conf} \
    && sed -i -e "s/^;clear_env = no$/clear_env = no/" ${fpm_conf} \
    && sed -i -e "s/unix:upstream/unix:\/run\/php\/php7.2-fpm.sock/g" ${nginx_conf} \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Supervisor config
ADD ./configs/supervisord.conf /etc/supervisord.conf

USER root
# Add Scripts
RUN mkdir -p /var/run/php
RUN mkdir -p /etc/nginx/custom-sites
RUN mkdir -p /etc/nginx/upstream
RUN mkdir -p /etc/nginx/common-configs

COPY ./configs/upstream /etc/nginx/upstream/
COPY ./configs/common-configs /etc/nginx/common-configs/
COPY ./configs/custom-sites /etc/nginx/custom-sites/


ADD ./start.sh /start.sh
RUN chmod +x /start.sh


EXPOSE 80

CMD ["/start.sh"]