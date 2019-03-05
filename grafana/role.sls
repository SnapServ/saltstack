{% from slspath ~ '/init.sls' import role, software %}

{{ software.repository(
  state_id='grafana/repository',
  name='grafana',
  sources=role.vars.repository_sources,
  gpg_key_url=role.vars.repository_gpg_key_url,
) }}

grafana/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}
    - require:
      - grafana/repository

grafana/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: True
    - reload: True
    - require:
      - pkg: grafana/packages
