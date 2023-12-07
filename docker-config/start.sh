#!/bin/bash

if [ -z "$1" ]; then
  echo 'missing argument'
  exit 1
fi

if [ $1 == 'shibboleth' ]; then
  cp -a /etc/shibboleth_confd /etc/confd
  /usr/local/bin/confd -onetime -backend env || { echo 'confd failed' ; exit 1; }
  a2dismod auth_mellon
  a2ensite default-ssl
  exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
fi
if [ $1 == 'mellon' ]; then
  cp -a /etc/mellon_confd /etc/confd
  /usr/local/bin/confd -onetime -backend env || { echo 'confd failed' ; exit 1; }
  
  mkdir -p /usr/local/apache2/mellon/metadata/
  curl -o /usr/local/apache2/mellon/metadata/idp.xml http://mdr/idp.xml
  ls -l /usr/local/apache2/mellon/metadata/

  a2dismod shib
  a2disconf shib
  a2ensite mod_auth_mellon
  apache2ctl -D FOREGROUND
fi

 echo 'invalid argument'
