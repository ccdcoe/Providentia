### Versioning

Providentia has one API version working at the moment:

1. APIv3

The API is using JSON format and is read-only - no altering the data in any way. Successful responses contain `result` key, errors contain `error` and optionally `code` key.

### Authentication

Providentia uses OpenID Connect for access management, both in web-application and API.
The authentication provider for this instance is: <%= Rails.configuration.oidc_issuer %>

An access token is required in order to use the API. The instructions on how to retrieve this token differ from provider to provider, but easiest method is via password grant flow.

After obtaining the access token, it should be added to the API request in `Authorization` header:

```
Authorization: Token agjvnY1GYqYHT8BcEi2Uv3C9
```

or

```
Authorization: Bearer agjvnY1GYqYHT8BcEi2Uv3C9
```

#### Local API tokens

It is also possible to use locally generated API tokens for testing purposes. This is is not a recommended way of using the API for long-term operation.

The personal API tokens can be generated at <%= link_to api_tokens_path %>

The generated token is shown to user only once

### Errors

If an error occurs while processing the API request, the response will contain a matching status code along with formatted response with a short error message.

| Error                                                | Response code |
| ---------------------------------------------------- | ------------- |
| Access token not accepted                            | 401           |
| Token accepted, but not authorized for this endpoint | 403           |
| Requested resource not found                         | 404           |

### APIv3 endpoints

All API calls are scoped under `/api/v3/` path

#### /

This endpoint returns a list of accessible environments - their ID and name

Example:

```json
{
  "result": [
    {
      "id": "te",
      "name": "Test Exercise"
    }
  ]
}
```

#### /:environment_id

This endpoint returns information about specific environment, if it is accessible
Example:

```json
{
  "result": {
    "id": "te",
    "name": "Test Exercise",
    "description": null,
    "teams": {
      "blue": [1, 2, 3, 4, 5],
      "blue_dev": [5]
    }
  }
}
```

#### /:environment_id/hosts

Example:

```json
{
  "result": [
    "fw1",
    "fw2"
    "server",
    "ws"
  ]
}
```

#### /:environment_id/hosts/:id

Example:

```json
{
  "result": {
    "id": "server",
    "owner": null,
    "description": null,
    "role": "server",
    "team_name": "blue",
    "visibility": "public",
    "hardware_cpu": null,
    "hardware_ram": null,
    "hardware_primary_disk_size": null,
    "tags": ["team_blue"],
    "capabilities": [],
    "services": [],
    "sequence_tag": null,
    "sequence_total": null,
    "instances": [
      {
        "id": "server_t01",
        "vm_name": "te_",
        "team_unique_id": "server",
        "hostname": "server",
        "domain": "",
        "fqdn": "",
        "connection_address": null,
        "interfaces": [
          {
            "network_id": "blu",
            "cloud_id": "BLU01",
            "domain": "test.exercise",
            "fqdn": "server.test.exercise",
            "egress": true,
            "connection": false,
            "addresses": [
              {
                "pool_id": "default-v6-corporate",
                "mode": "ipv6_static",
                "connection": false,
                "address": "2a07:a:b:1:d::666/80",
                "dns_enabled": false,
                "gateway": "2a07:a:b:1:d::1"
              }
            ]
          }
        ],
        "checks": [],
        "config_map": {},
        "team_nr": 1,
        "team_nr_str": "01"
      },
      ...
      {
        "id": "server_t05",
        "vm_name": "te_",
        "team_unique_id": "server",
        "hostname": "server",
        "domain": "",
        "fqdn": "",
        "connection_address": null,
        "interfaces": [
          {
            "network_id": "blu",
            "cloud_id": "BLU05",
            "domain": "test.exercise",
            "fqdn": "server.test.exercise",
            "egress": true,
            "connection": false,
            "addresses": [
              {
                "pool_id": "default-v6-corporate",
                "mode": "ipv6_static",
                "connection": false,
                "address": "2a07:a:b:5:d::666/80",
                "dns_enabled": false,
                "gateway": "2a07:a:b:5:d::1"
              }
            ]
          }
        ],
        "checks": [],
        "config_map": {},
        "team_nr": 5,
        "team_nr_str": "05"
      }
    ]
  }
}
```

#### /:environment_id/inventory

All hosts in the environment concatenated into a single `result` array. See [/:environment_id/hosts/:id] for format.

#### /:environment_id/networks

Example:

```json
{
  "result": [
    {
      "id": "sinet",
      "name": "SINET",
      "description": "This is Internet",
      "team": "green",
      "instances": [
        {
          "cloud_id": "VLAN22-CRX-LOGS",
          "domains": ["not.domain.test.exercise"],
          "address_pools": [
            {
              "id": "default-default-ipv4",
              "ip_family": "v4",
              "network_address": "192.168.0.1/24",
              "gateway": "192.168.0.1"
            },
            {
              "id": "default-default-ipv6",
              "ip_family": "v6",
              "network_address": "beef::/5",
              "gateway": "b800::1"
            }
          ],
          "config_map": null
        }
      ]
    },
    {
      "id": "nr1",
      "name": "numbered",
      "description": null,
      "team": "blue",
      "instances": [
        {
          "cloud_id": "team1",
          "domains": ["team1.test.exercise"],
          "address_pools": [
            {
              "id": "default-default-ipv4",
              "ip_family": "v4",
              "network_address": "10.20.1.0/24",
              "gateway": "10.20.1.1"
            }
          ],
          "config_map": {
            "team_specific_string": "test - 1"
          }
        },
        {
          "cloud_id": "team2",
          "domains": ["team2.test.exercise"],
          "address_pools": [
            {
              "id": "default-default-ipv4",
              "ip_family": "v4",
              "network_address": "10.20.2.0/24",
              "gateway": "10.20.2.1"
            }
          ],
          "config_map": {
            "team_specific_string": "test - 2"
          }
        },
        {
          "cloud_id": "team3",
          "domains": ["team3.test.exercise"],
          "address_pools": [
            {
              "id": "default-default-ipv4",
              "ip_family": "v4",
              "network_address": "10.20.3.0/24",
              "gateway": "10.20.3.1"
            }
          ],
          "config_map": {
            "team_specific_string": "test - 3"
          }
        },
        {
          "cloud_id": "team4",
          "domains": ["team4.test.exercise"],
          "address_pools": [
            {
              "id": "default-default-ipv4",
              "ip_family": "v4",
              "network_address": "10.20.4.0/24",
              "gateway": "10.20.4.1"
            }
          ],
          "config_map": {
            "team_specific_string": "test - 4"
          }
        }
      ]
    }
  ]
}
```

#### /:environment_id/networks/:id

#### /:environment_id/services

#### /:environment_id/services/:id

#### /:environment_id/capabilities

#### /:environment_id/tags

Example:

```json
{
  "result": [
    {
      "id": "team_green",
      "name": "Green",
      "config_map": {
        "team_color": "Green"
      },
      "children": []
    },
    {
      "id": "team_red",
      "name": "Red",
      "config_map": {
        "team_color": "Red"
      },
      "children": []
    },
    {
      "id": "team_blue",
      "name": "Blue",
      "config_map": {
        "team_color": "Blue"
      },
      "children": []
    },
    {
      "id": "team_yellow",
      "name": "Yellow",
      "config_map": {
        "team_color": "Yellow"
      },
      "children": []
    },
    {
      "id": "team_white",
      "name": "White",
      "config_map": {
        "team_color": "White"
      },
      "children": []
    },
    {
      "id": "os_macos",
      "name": "macOS",
      "config_map": {},
      "children": []
    },
    {
      "id": "os_network_devices",
      "name": "Network devices",
      "config_map": {},
      "children": []
    },
    {
      "id": "os_linux",
      "name": "Linux",
      "config_map": {},
      "children": ["os_ubuntu_22_04", "os_kali_2022_1"]
    },
    {
      "id": "os_ubuntu_22_04",
      "name": "Ubuntu 22.04",
      "config_map": {},
      "children": []
    },
    {
      "id": "os_windows",
      "name": "Windows",
      "config_map": {},
      "children": []
    },
    {
      "id": "os_kali_2022_1",
      "name": "Kali 2022.1",
      "config_map": {},
      "children": []
    },
    {
      "id": "zone_out",
      "name": "TORU",
      "config_map": {
        "domain": "test.exercise"
      },
      "children": []
    },
    {
      "id": "zone_isp1",
      "name": "isp-link1",
      "config_map": {
        "domain": "test.exercise"
      },
      "children": []
    },
    {
      "id": "zone_isp2",
      "name": "isp-link2",
      "config_map": {
        "domain": "test.exercise"
      },
      "children": []
    },
    {
      "id": "zone_sinet",
      "name": "SINET",
      "config_map": {
        "domain": "test.exercise"
      },
      "children": []
    },
    {
      "id": "zone_blu",
      "name": "BLUENET",
      "config_map": {
        "domain": "test.exercise"
      },
      "children": []
    },
    {
      "id": "sequential_ws1",
      "name": "sequential_ws1",
      "config_map": {},
      "children": []
    },
    {
      "id": "team_green_bt_numbered",
      "name": "team_green_bt_numbered",
      "config_map": {},
      "children": []
    }
  ]
}
```
