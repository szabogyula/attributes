#!/bin/bash

/usr/local/bin/confd -onetime -backend env || { echo 'confd failed' ; exit 1; }
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
