#!/bin/bash
set -e

if [ $1 == 'shibboleth' ]; then
  cp -a /etc/shibboleth_confd /etc/confd
  # /usr/local/bin/confd -onetime -backend env || { echo 'confd failed' ; exit 1; }
  a2dismod auth_mellon
  a2ensite default-ssl
  exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
else
  sed -i "s#http:\/\/localhost:8081#https://${VIRTUAL_HOST}#g" /etc/mellon/mellon_metadata.xml
  mkdir /var/www/html/mellon/sp
  cp -a /etc/mellon/mellon_metadata.xml /var/www/html/mellon/sp/metadata.xml
  
  sed -i "s#\# ServerName.*#ServerName https://${VIRTUAL_HOST}#g" /etc/apache2/sites-available/mod_auth_mellon.conf
  sed -i "s#\# MellonDiscoveryURL.*#MellonDiscoveryURL ${DISCOVERY_URL}#g" /etc/apache2/sites-available/mod_auth_mellon.conf

  curl -o /etc/mellon/metadata/idp.xml ${IDP_METADATA_URL:-http://mdr/idp.xml}

  a2dismod shib
  a2disconf shib
  a2ensite mod_auth_mellon
  apache2ctl -D FOREGROUND
fi
