#!/bin/bash

if [ $1 == 'shibboleth' ]; then
  cp -a /etc/shibboleth_confd /etc/confd
  # /usr/local/bin/confd -onetime -backend env || { echo 'confd failed' ; exit 1; }
  a2dismod auth_mellon
  a2ensite default-ssl
  exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
else
  cp -a /etc/mellon_confd /etc/confd
  # /usr/local/bin/confd -onetime -backend env || { echo 'confd failed' ; exit 1; }
  
  curl -o /etc/mellon/metadata/idp.xml ${IDP_METADATA_URL:-http://mdr/idp.xml}
  ls -l /etc/mellon/metadata/

  a2dismod shib
  a2disconf shib
  a2ensite mod_auth_mellon
  apache2ctl -D FOREGROUND
fi
