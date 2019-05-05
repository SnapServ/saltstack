{% from slspath ~ '/init.sls' import role %}

include:
  - .common

icinga/master/zones-config:
  file.managed:
    - name: {{ role.vars.zones_config|yaml_dquote }}
    - source: {{ role.tpl_path('master/zones.conf.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        vars: {{ role.vars|yaml }}
    - watch_in:
      - service: icinga/service
