#!/bin/bash

if [ -z "$ENTITY_ID" ]; then
    echo "Need to set ENTITY_ID"
    exit 1
fi
if [ -z "$DISCOVERY_URL" ]; then
    echo "Need to set DISCOVERY_URL"
    exit 1
fi
if [ -z "$SUPPORT_CONTACT" ]; then
    echo "Need to set SUPPORT_CONTACT"
    exit 1
fi
if [ -z "$XML_METADATA_PROVIDER" ]; then
    echo "Need to set XML_METADATA_PROVIDER"
    exit 1
fi
if [ -z "$DYNAMIC_METADATA_PROVIDER" ]; then
    echo "Need to set DYNAMIC_METADATA_PROVIDER"
    exit 1
fi
if [ -z "$ATTRIBUTE_RESOLVERS" ]; then
    echo "Need to set ATTRIBUTE_RESOLVERS"
    exit 1
fi

sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

sed -i "s#%ENTITY_ID%#$ENTITY_ID#g"                                 /etc/shibboleth/shibboleth2.xml
sed -i "s#%DISCOVERY_URL%#$DISCOVERY_URL#g"                         /etc/shibboleth/shibboleth2.xml
sed -i "s#%SUPPORT_CONTACT%#$SUPPORT_CONTACT#g"                     /etc/shibboleth/shibboleth2.xml
sed -i "s#%XML_METADATA_PROVIDER%#$XML_METADATA_PROVIDER#g"         /etc/shibboleth/shibboleth2.xml
sed -i "s#%DYNAMIC_METADATA_PROVIDER%#$DYNAMIC_METADATA_PROVIDER#g" /etc/shibboleth/shibboleth2.xml
sed -i "s#%ATTRIBUTE_RESOLVERS%#$ATTRIBUTE_RESOLVERS#g"             /etc/shibboleth/shibboleth2.xml

service shibd start

source /etc/apache2/envvars

exec apache2 -D FOREGROUND
