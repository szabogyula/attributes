# attribute checker

IdP and Attribute Authority attribute release checker app.

Very simple php silex app, shibboleth secured service. After login it shows the attributes and values what IdP and
Attribute Authorities released.

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