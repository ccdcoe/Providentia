# Providentia

> tool for cyber-exercise technical management, named after ancient Roman personification of foresight, provision and planning.

<div align="center">

![Providentia image](/app/assets/images/providentia.jpg)

</div>

**Providentia** was developed at [CCDCOE](https://ccdcoe.org) to improve development of their flagship exercises and released to open source in late 2022.

## Project description

Providentia manages the technical inventory of a cyber exercise environment: networks, hosts and more. This centralizes this information and provides a single source of truth via JSON API. It integrates best with [Catapult](https://github.com/ClarifiedSecurity/catapult) deployment app, also developed by Clarified Security, but has been adapted to work with other tools and applications.

The main use case is consuming the API to create [Ansible](https://www.ansible.com/) inventory in order to deploy networks and hosts to a cyber range environment.

Since its creation in 2020, Providentia has been used to plan and deploy numerous Locked Shields (LS), Crossed Swords (XS) and non-public cyber exercises.

## Features

- Can be used to manage infrastructure, defensive or offensive exercises
  - Supports multiple identical cloned environments for each actor
- Planning and design of exercise networking
  - Templating engine, allowing for value substitution in addresses, domains, etc.
  - Supports multiple address pool within same layer 2
  - Supports multiple NIC-s per host
  - Avoids address conflicts and overlaps
  - Supports static, dynamic, virtual addressing
- Hosts inventory: virtual machines, containers and physical devices
- Enabled describing detailed services, which can be used to perform automatic checks
  - Powerful pattern matching to easily apply services to multiple hosts at once
  - Flexible configuration for individual checks
- Authentication handled by external SSO via OpenID Connect
- JSON API, with accompanying Ansible inventory plugin as part of [nova.core](https://github.com/novateams/nova.core) collection

---

## Getting started

While it is possible to run Providentia on a host directly, the recommended approach is to use Docker containers. The requirements on the host are: make, Python 3, Docker, and Docker Compose version > 2.

The bundled Makefile can be used to set the environment (development or production) by using `make config` command. The configurator script is automatically launched if no config has been set before.

To quickly launch Providentia locally, it is recommended to use development mode. TL;DR:

```sh
git clone https://github.com/ClarifiedSecurity/Providentia.git
cd Providentia
make config # choose dev
make build
make start
```

### Running in production

> The default make-based production configuration is insecure! Be warned!

The make based bootstrap can be used to start the application in production mode as well. It is primarily meant to be inspiration on how a production environment might look like - it is **not** meant to be used without altering it first.

The steps for setting up are similar to dev instructions above, except answer 'prod' when prompted for environment. Have a look at `docker/prod` directory on how the setup works and adapt it to your needs using configuration files:

- web.env
- db.env
- docker-compose.yml
- initdb.sql

## Default setup

This applies to development and production environment, when ran with default Makefile and configuration. The app is deployed using local containers:

- Keycloak for authentication (SSO)
- Redis for caching and session storage
- Postgres for database
- App container
- Caddy as reverse proxy

After bootup, Providentia can be accessed at [http://providentia.localhost](http://providentia.localhost) and Keycloak will be running at [http://keycloak.localhost](http://keycloak.localhost). You may need to trust the self-signed TLS certificate if running production mode.

### Credentials

**Keycloak**:

- u: `admin` p: `adminsecret`

**Providentia**:

On first development mode boot, a sample exercise is created for you - "Test exercise".

- u: `providentia.admin` p: `providentia.admin-pass` - has access to everything.
- u: `providentia.rt` p: `providentia.rt-pass` - has access to Test Exercise as RT member (can see RT virtual machines).
- u: `providentia.gt` p: `providentia.gt-pass` - has access to Test Exercise as GT member (cannot see RT virtual machines)
- u: `providentia.teadmin` p: `providentia.teadmin-pass` - has access to Test Exercise as environment administrator

## Data model

TODO

## API documentation

TODO

## Roadmap / upcoming features

- Introduce actors and rework access control
- Import/Export of environments
- Cloning of hosts

## Credits

Providentia was created and is maintaned by [mromulus](https://github.com/mromulus).

Thanks to [Clarified Security](https://clarifiedsecurity.com) for enabling this work to continue.

<p align="center">
  <a href="https://clarifiedsecurity.com">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://user-images.githubusercontent.com/393247/223430817-82d6422c-9fe0-4836-a401-6eb0f588dc7a.png">
      <source media="(prefers-color-scheme: light)" srcset="https://user-images.githubusercontent.com/393247/223430780-9072ba4b-8c7c-4d55-8f5a-a8107d7cce00.png">
      <img alt="Clarified Security logo" src="https://user-images.githubusercontent.com/393247/223430780-9072ba4b-8c7c-4d55-8f5a-a8107d7cce00.png">
    </picture>
  </a>
</p>

## License

This project is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
