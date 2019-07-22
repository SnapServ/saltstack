{% from slspath ~ '/init.sls' import role, software %}

{{ software.repository(
  state_id='puppet/repository',
  name='puppet',
  sources=role.vars.puppet_repository_sources,
  gpg_key_url=role.vars.puppet_repository_gpg_key_url,
) }}

{{ software.repository(
  state_id='foreman/repository',
  name='foreman',
  sources=role.vars.foreman_repository_sources,
  gpg_key_url=role.vars.foreman_repository_gpg_key_url,
) }}

foreman/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}
    - require:
      - puppet/repository
      - foreman/repository
