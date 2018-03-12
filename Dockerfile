FROM debian:jessie
MAINTAINER Lukasz Burylo <lukasz@burylo.com>


RUN apt-get update && \
    apt-get install -y --force-yes --no-install-recommends ca-certificates wget apt-transport-https lsb-release git-core

RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg &&\
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --force-yes --no-install-recommends apache2 php7.1 php7.1-mysql php7.1-xml php7.1-gd php7.1-mbstring php7.1-curl

ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars
RUN set -ex \
    && . "$APACHE_ENVVARS" \
    && ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log" \
    && ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log" \
    && ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log"

RUN a2enmod rewrite
RUN cp /usr/share/zoneinfo/Europe/Warsaw /etc/localtime

EXPOSE 80

COPY 000-default.conf /etc/apache2/sites-available/
COPY apache2-foreground /usr/local/bin/
WORKDIR /var/www/html
CMD ["apache2-foreground"]
