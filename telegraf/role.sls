{% from slspath ~ '/init.sls' import role, software %}

{{ software.repository(
  state_id='telegraf/repository',
  name='influxdata',
  sources=role.vars.repository_sources,
  gpg_key_url=role.vars.repository_gpg_key_url,
) }}

telegraf/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}
    - require:
      - telegraf/repository

telegraf/config:
  file.managed:
    - name: {{ role.vars.config_path|yaml_dquote }}
    - source: {{ role.tpl_path('telegraf.conf.j2')|yaml_dquote }}
    - check_cmd: {{ role.vars.config_check_cmd|yaml_dquote }}
    - template: 'jinja'
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: telegraf/packages

telegraf/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: True
    - reload: True
    - watch:
      - file: telegraf/config
