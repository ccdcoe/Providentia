# Providentia

> tool for cyber-exercise technical management, named after ancient Roman personification of foresight, provision and planning.

<div align="center">

![Providentia image](/app/assets/images/providentia.jpg)

</div>

**Providentia** was developed at [CCDCOE](https://ccdcoe.org) to improve development of their flagship exercises and released to open source in late 2022.

## Project description

Providentia manages the technical inventory of a cyber exercise environment: networks, hosts and more. This centralizes the information and provides a single source of truth, which can be used by other tools using its JSON API.

The main use case is integrating consume the API to create [Ansible](https://www.ansible.com/) inventory in order to deploy networks and hosts to a cyber range environment.

Since its creation in 2020, Providentia has been used to plan and deploy numerous Locked Shields (LS), Crossed Swords (XS) and non-public cyber exercises.

## Features

- Can be used to manage infrastructure, defensive or offensive exercises
  - Supports multiple identical environments for each actor
- Planning and design of exercise networking
  - Templating engine, allowing for value substitution in addresses, domains, etc.
  - Supports multiple address pool within same layer 2
  - Supports multiple NIC-s per host
  - Avoids address conflicts and overlaps
  - Supports static, dynamic, virtual addressing
- Hosts inventory: virtual machines, containers and physical devices
- Allows describing services on hosts, which can be used to perform automatic checks
- Authentication handled by external SSO via OpenID Connect
- JSON API, with accompanying Ansible inventory plugin (to be made public soon)

---

## Getting started

While it is possible to run Providentia on a host directly, the recommended approach is to use Docker containers. The only requirement for this is Docker and Docker Compose version > 2.

The easiest way is to run Providentia locally, in development mode. The accompanying Makefile is designed to be used for development and is the recommended way of getting up and running.

TL;DR:

```sh
git clone https://github.com/ClarifiedSecurity/Providentia.git
cd Providentia
make build
make start
```

This will build the app image, start keycloak (used for SSO) and finally start Providentia. After bootup, Providentia can be accessed at [http://providentia.localhost](http://providentia.localhost) and Keycloak will be running at [http://keycloak.localhost](http://keycloak.localhost). You may need to trust the self-signed TLS certificate.

### Credentials

**Keycloak**:

- u: `admin` p: `adminsecret`

**Providentia**:

On first development mode boot, a sample exercise is created for you - "Test exercise".

- u: `providentia.admin` p: `providentia.admin-pass` - has access to everything.
- u: `providentia.rt` p: `providentia.rt-pass` - has access to Test Exercise as RT member (can see RT virtual machines).
- u: `providentia.gt` p: `providentia.gt-pass` - has access to Test Exercise as GT member (cannot see RT virtual machines)
- u: `providentia.teadmin` p: `providentia.teadmin-pass` - has access to Test Exercise as environment administrator

## Running in production

There is an incomplete example on how to run Providentia in production in `docker/prod` directory.
The `docker-compose.yml` file by itself does not include ingress or reverse proxy, there is an example provided in `proxy.yml`, but you can substitute with any reverse proxy.

There are multiple example files, which need to be customized based on the environment:

- web.env.sample
- db.env.sample
- proxy.yml

The example can then be run with:

```sh
cd docker/prod
docker compose -f docker-compose.yml -f proxy.yml up -d
```

## Data model

TODO

## API documentation

TODO

## Roadmap / upcoming features

- Introduce actors and rework access control
- Revamp services to be more flexible and powerful
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
