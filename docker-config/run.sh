#!/bin/bash

if [ -z "$ENTITY_ID" ]; then
    echo "Need to set ENTITY_ID"
    exit 1
fi

if [ -z "$SUPPORT_CONTACT" ]; then
    echo "Need to set SUPPORT_CONTACT"
    exit 1
fi

if [ -z "$ATTRIBUTE_RESOLVERS" ]; then
    echo "Need to set ATTRIBUTE_RESOLVERS"
    exit 1
fi

if [ -n "$DISCOVERY_URL" ]; then
    export SSO_ELEMENT="<SSO discoveryProtocol=\"SAMLDS\" discoveryURL=\"$DISCOVERY_URL\">SAML2</SSO>"

fi

if [ -n "$IDP_ENTITY_ID" ] && [ -z "$SSO_ELEMENT" ]; then
   export SSO_ELEMENT="<SSO entityID=\"$IDP_ENTITY_ID\">SAML2</SSO>"
fi

if [ -z "$SSO_ELEMENT" ]; then
    echo "Need to set exactly one of DISCOVERY_URL or IDP_ENTITY_ID"
    exit 1
fi

# METADATA PROVIDERS

if [ -z "$XML_METADATA_PROVIDER" ] && [ -z "$DYNAMIC_METADATA_PROVIDER" ]; then
    echo "Need to set XML_METADATA_PROVIDER or DYNAMIC_METADATA_PROVIDER"
    exit 1
fi

export XML_METADATA_PROVIDER_ELEMENT=""
export DYNAMIC_METADATA_PROVIDER_ELEMENT=""

if [ -n "$XML_METADATA_PROVIDER" ]; then
    export XML_METADATA_PROVIDER_ELEMENT="<MetadataProvider type=\"XML\" url=\"$XML_METADATA_PROVIDER\" reloadInterval=\"1800\"> <!--<MetadataFilter type=\"Signature\" certificate=\"href-metadata-signer-2011.crt\"/>--> </MetadataProvider>"
fi
if [ -n "$DYNAMIC_METADATA_PROVIDER" ]; then
    export DYNAMIC_METADATA_PROVIDER_ELEMENT="<MetadataProvider type=\"Dynamic\" ignoreTransport=\"true\"> <Subst>$DYNAMIC_METADATA_PROVIDER/\$entityID</Subst> <!--<MetadataFilter type=\"Signature\" certificate=\"mdx-test-signer-2015.crt\"/>--> </MetadataProvider>"
fi

# AuthnContextClassRef

export AUTHN_CONTEXT_CLASS_REF_PARAMETER=""
if [ -n "$AUTHN_CONTEXT_CLASS_REF" ]; then
    export AUTHN_CONTEXT_CLASS_REF_PARAMETER=authnContextClassRef=\""$AUTHN_CONTEXT_CLASS_REF"\"
fi

sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

sed -i "s#%ENTITY_ID%#$ENTITY_ID#g"                                                 /etc/shibboleth/shibboleth2.xml
sed -i "s#%SSO_ELEMENT%#$SSO_ELEMENT#g"                                             /etc/shibboleth/shibboleth2.xml
sed -i "s#%SUPPORT_CONTACT%#$SUPPORT_CONTACT#g"                                     /etc/shibboleth/shibboleth2.xml

sed -i "s#%XML_METADATA_PROVIDER_ELEMENT%#$XML_METADATA_PROVIDER_ELEMENT#g"         /etc/shibboleth/shibboleth2.xml
sed -i "s#%DYNAMIC_METADATA_PROVIDER_ELEMENT%#$DYNAMIC_METADATA_PROVIDER_ELEMENT#g" /etc/shibboleth/shibboleth2.xml

sed -i "s#%ATTRIBUTE_RESOLVERS%#$ATTRIBUTE_RESOLVERS#g"                             /etc/shibboleth/shibboleth2.xml

sed -i "s#%AUTHN_CONTEXT_CLASS_REF_PARAMETER%#$AUTHN_CONTEXT_CLASS_REF_PARAMETER#g" /etc/shibboleth/shibboleth2.xml

service shibd start

source /etc/apache2/envvars

exec apache2 -D FOREGROUND
