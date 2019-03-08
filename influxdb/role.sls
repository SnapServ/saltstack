{% from slspath ~ '/init.sls' import role, software %}

{{ software.repository(
  state_id='influxdb/repository',
  name='influxdata',
  sources=role.vars.repository_sources,
  gpg_key_url=role.vars.repository_gpg_key_url,
) }}

influxdb/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}
    - require:
      - influxdb/repository

influxdb/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: True
    - reload: True
    - require:
      - pkg: influxdb/packages
