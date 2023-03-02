## Templating

Providentia has templating engine, which is using [Liquid](https://shopify.dev/api/liquid) language as base.

Main use case is using dynamic variables in `Network` or `VirtualMachine` fields, allowing for greater flexibility in designing the environment.

Currently, following variables can be used:

1. `team_nr` - the number of Blue team, as iterated over the environment maximum
1. `team_nr_str` - the number of Blue team, as iterated over the environment maximum, leftpadded with zeroes.
1. `seq` - sequential number, if a `VirtualMachine` is configured with a custom deploy count.

### Network

When `{{ team_nr }}` or `{{ team_nr_str }}` is added to compatible field (domain, cloud ID, network address), the network is switched to be in numbered mode. Any virtual machine attached to this network will be forced to deploy in "one per every blue team" mode.

### Filters

Commonly used filter patterns, when blue team count equals _5_:

| Pattern                                    | Description                                                                        | Resulting values             |
| ------------------------------------------ | ---------------------------------------------------------------------------------- | ---------------------------- |
| 10.{{ team_nr }}.1.0/24                    | basic substitution                                                                 | 10. **[1-5]** .1.0/24        |
| a:b:c:d:12{{ team_nr_str }}::/80           | leftpad equivalent, makes the substitution always be 2 characters, with 0 in front | a:b:c:d:12 **[01-05]** ::/80 |
| 100.64.{{ team_nr &vert; plus: 200 }}.0/24 | offset applied to addressing, allows for more efficient use of address space       | 100.64. **[201-205]** .0/24  |
