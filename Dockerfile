# szabogyula/attribute
FROM php:7.4-apache

# install required packages
RUN apt-get update \
    && apt-get install -yq git libapache2-mod-shib libapache2-mod-auth-mellon unzip vim silversearcher-ag supervisor\
    && rm -rf /var/lib/apt/lists/* \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#configure apache
ADD docker-config/apache_cert/* /etc/apache2/cert/
RUN a2dissite 000-default default-ssl && a2enmod ssl && a2enmod rewrite
ENV APACHE_LOG_DIR /var/log/apache2

ADD docker-config/sites-available /etc/apache2/sites-available
ADD docker-config/mellon /etc/mellon

## build shib application
ADD app /var/www/html/shib
RUN cd /var/www/html/shib && composer install

# add shibboleth-sp logout page assets
ADD shibboleth-sp /var/www/html/shib/web/shibboleth-sp

## build mellon application
ADD mellon /var/www/html/mellon
RUN cd /var/www/html/mellon && composer install

# create shibboleth and mellon cert directory
RUN mkdir /etc/shibboleth/cert
RUN mkdir -p /etc/mellon/cert

# install the runner
ADD docker-config/start.sh /start.sh

ADD docker-config/shibboleth_confd /etc/shibboleth_confd

COPY docker-config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN echo "Mutex posixsem" >> /etc/apache2/apache2.conf

ENV LOGLEVEL INFO

RUN ln -sf /dev/stdout /var/log/apache2/access.log
RUN ln -sf /dev/stdout /var/log/apache2/error.log 
RUN mkdir -p /etc/apache2/logs
RUN ln -sf /dev/stdout /etc/apache2/logs/mellon_diagnostics 

## HEALTHCHECK CMD curl http://localhost/Shibboleth.sso/Metadata
EXPOSE 80 443

ENTRYPOINT ["/start.sh"]
CMD ["shibboleth"]
