{% from slspath ~ '/init.sls' import role, software %}

{{ software.repository(
  state_id='syncthing/repository',
  name='syncthing',
  sources=role.vars.repository_sources,
  gpg_key_url=role.vars.repository_gpg_key_url,
) }}

syncthing/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}
    - require:
      - syncthing/repository
