# szabogyula/attribute
FROM php:7.4-apache

# install required packages
RUN apt-get update \
    && apt-get install -yq git libapache2-mod-shib unzip vim silversearcher-ag supervisor\
    && rm -rf /var/lib/apt/lists/* \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#configure apache
ADD docker-config/apache_cert/*                  /etc/apache2/cert/
RUN a2ensite default-ssl && a2dissite 000-default && a2enmod ssl && a2enmod rewrite
ENV APACHE_LOG_DIR /var/log/apache2

## build application
ADD app /var/www/html
RUN cd /var/www/html && composer install

# create shibboleth cert directory
RUN mkdir /etc/shibboleth/cert

# add shibboleth-sp logout page assets
ADD shibboleth-sp                                 /var/www/html/web/shibboleth-sp

# install the runner
ADD docker-config/start.sh /start.sh
ADD tools/confd-0.16.0-linux-amd64 /usr/local/bin/confd

RUN chmod +x /usr/local/bin/confd

ADD docker-config/confd /etc/confd

COPY docker-config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENV LOGLEVEL INFO

HEALTHCHECK CMD curl http://localhost/Shibboleth.sso/Metadata
EXPOSE 80 443
CMD /start.sh
