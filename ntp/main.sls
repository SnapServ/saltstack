{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import ntp %}

ntp/packages:
  pkg.installed:
    - pkgs: {{ ntp.packages|yaml }}

ntp/config:
  file.managed:
    - name: {{ ntp.ntpconf_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['ntpconf.j2'],
        lookup='ntp-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        ntp: {{ ntp|yaml }}
    - require:
      - pkg: ntp/packages

ntp/service:
  service.running:
    - name: {{ ntp.service|yaml_dquote }}
    - enable: True
    - watch:
      - file: ntp/config

{%- for _service in ntp.service_blacklist %}
{%- if salt['service.available'](_service) %}

ntp/service-blacklist/{{ _service }}:
  service.dead:
    - name: {{ _service|yaml_dquote }}
    - enable: False

{%- endif %}
{%- endfor %}
