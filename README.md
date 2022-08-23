<div align="center">

![Providentia image](/app/assets/images/providentia.jpg)

</div>

**Providentia** is a tool to manage (mostly) virtualized infrastructure knowledge. Born out of necessity to build the world's largest live-fire cyber exercise - Locked Shields - it can also be used to organize infrastructure or smaller scale exercises.

# Features

- Fully configurable amount of blue teams
- Planning and design of exercise networks
- Defining (virtual) machines in environments
- Rich API

## Development mode

Use `make start` to build and start Providentia in development mode. App will be accessible at `http://providentia.localhost`; keycloak is running at `http://keycloak.localhost`.

The first exercise is created for you - "Test exercise".

### Credentials

**Keycloak**:\
u: `admin` p: `adminsecret`

**Providentia**:

- u: `providentia.admin` p: `providentia.admin-pass` - has access to everything.
- u: `providentia.rt` p: `providentia.rt-pass` - has access to Test Exercise as RT member (can see RT stuff).
- u: `providentia.gt` p: `providentia.gt-pass` - has access to Test Exercise as GT member (cannot see RT stuff)
- u: `providentia.teadmin` p: `providentia.teadmin-pass` - has access to Test Exercise as environment administrator
