# attribute checker

IdP and Attribute Authority attribute release checker app.

Very simple php silex app, shibboleth secured service. After login it shows the attributes and values what IdP and
Attribute Authorities released.

# hub.docker.com

https://hub.docker.com/r/szabogyula/attributes

# Build

```bash
docker build -t attributes .
```

# Configuration

You can configure the brand and the logo and the type of relevant the attributes those define the federation.

```yaml

---
brand: attributes
logo: images/logo.png
attributetypes:
    mandatory:
        - urn:oid:1.3.6.1.4.1.5923.1.1.1.10 # "eduPersonTargetedID",
        - urn:oid:1.3.6.1.4.1.5923.1.1.1.9  # "eduPersonScopedAffiliation",
        - urn:oid:1.3.6.1.4.1.5923.1.1.1.6  # "eduPersonPrincipalName",
    recommended:
        - urn:oid:2.16.840.1.113730.3.1.241 # "displayName",
        - urn:oid:0.9.2342.19200300.100.1.3 # "mail",
        - urn:oid:1.3.6.1.4.1.5923.1.1.1.7  # "eduPersonEntitlement",
```


# running docker container

You can use docker-compose, and read the .env.dist environment variables.

```
VIRTUAL_HOST=attributes.eduid.hu
ENTITY_ID=https://attributes.eduid.hu/ssp

# one of them
DISCOVERY_URL=https://ds-pending.eduid.hu/role/idp.ds
# IDP_ENTITY_ID=https://l-aai.sztaki.hu/idp

SUPPORT_CONTACT=info@eduteams.org
SUPPORT_CONTACT_SURNAME=Eduteams
SUPPORT_CONTACT_GIVEN_NAME=Support

# optional
XML_METADATA_PROVIDER=https://metadata.eduid.hu/current/href-pending.xml
# optional
DYNAMIC_METADATA_PROVIDER=http://mdx.eduid.hu/entities/$entityID
# optional
MDQ_METADATA_PROVIDER=https://mdx.eduid.hu/entities


# optional
# ATTRIBUTE_RESOLVERS=<AttributeResolver type="SimpleAggregation" attributeId="principalName" format="urn:oid:1.3.6.1.4.1.5923.1.1.1.6"><Entity>https://hexaa.eduid.hu/hexaa</Entity><Attribute Name="urn:oid:1.3.6.1.4.1.5923.1.1.1.7" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="eduPersonEntitlement"/></AttributeResolver>

# optional
# AUTHN_CONTEXT_CLASS_REF=http://mfa.eduteams.org/assurance/loa3

# optional if you run your sp behind ssl terminator proxy, like jwilder/nginx-proxy
# BEHIND_SSL_TERMINATOR_PROXY=true

# optional no ssl support, no apache certs...
# NOSSL=true

# optional create http endpoints in generated metadata instead of https
# METADATA_NOSSL_ENDPOINTS=true

# optional assertion encryption
# APPLICATION_DEFAULTS_ENCRYPTION=true

# optional shibboleth log level
# LOGLEVEL=INFO

# research-and-scolarship entity attribute
# ENTITYATTRIBUTE_RNS=true
```
