# szabogyula/attribute
FROM php:7.2.0-apache-stretch

# install required packages
RUN apt-get update \
    && apt-get install -yq git libapache2-mod-shib2 unzip supervisor\
    && rm -rf /var/lib/apt/lists/* \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# configure shibboleth sp
# confd ADD docker-config/shibboleth/shibboleth2.xml      /etc/shibboleth/
ADD docker-config/shibboleth/attribute-configs    /etc/shibboleth/attribute-configs
RUN rm -rf /etc/shibboleth/attribute-map.xml /etc/shibboleth/attribute-policy.xml
ADD docker-config/shibboleth/shibd.logger         /etc/shibboleth/
ADD docker-config/shibboleth/cert                 /etc/shibboleth/cert

#configure apache
ADD docker-config/apache_cert/*                  /etc/apache2/cert/
## confd ADD docker-config/apache_config/default-ssl.conf /etc/apache2/sites-available
RUN a2ensite default-ssl && a2dissite 000-default && a2enmod ssl && a2enmod rewrite
ENV APACHE_LOG_DIR /var/log/apache2

## build application
ADD app /var/www/html
RUN cd /var/www/html && composer install

# install the runner
ADD docker-config/start.sh /start.sh

RUN curl -sLo /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 && chmod +x /usr/local/bin/confd

ADD docker-config/confd /etc/confd

COPY docker-config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

HEALTHCHECK CMD curl http://localhost/Shibboleth.sso/Metadata
EXPOSE 80 443
CMD /start.sh
