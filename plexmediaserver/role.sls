{% from slspath ~ '/init.sls' import role, software %}

{{ software.repository(
  state_id='plexmediaserver/repository',
  name='plexmediaserver',
  sources=role.vars.repository_sources,
  gpg_key_url=role.vars.repository_gpg_key_url,
) }}

plexmediaserver/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}
    - require:
      - plexmediaserver/repository

plexmediaserver/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: True
    - require:
      - pkg: plexmediaserver/packages
