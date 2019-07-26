{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import icinga %}

include:
  - .common

icinga/master/zones-config:
  file.managed:
    - name: {{ icinga.zones_config|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['master/zones.conf.j2'],
        lookup='master-zones-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        icinga: {{ icinga|yaml }}
    - watch_in:
      - service: icinga/service
