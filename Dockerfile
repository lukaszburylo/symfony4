FROM debian:jessie
MAINTAINER Lukasz Burylo <lukasz@burylo.com>


RUN apt-get update && \
    apt-get install -y --force-yes --no-install-recommends ca-certificates wget apt-transport-https lsb-release git-core

RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg &&\
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --force-yes --no-install-recommends apache2 php7.1 php7.1-mysql php7.1-xml php7.1-gd php7.1-mbstring php7.1-curl

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" &&\
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" &&\
    php composer-setup.php --install-dir=/usr/bin --filename=composer &&\
    chmod +x /usr/bin/composer &&\
    php -r "unlink('composer-setup.php');"


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
