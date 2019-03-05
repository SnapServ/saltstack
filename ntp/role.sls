{% from slspath ~ '/init.sls' import role %}

ntp/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}

ntp/config:
  file.managed:
    - name: {{ role.vars.ntpconf_path|yaml_dquote }}
    - source: {{ role.tpl_path('ntpconf.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: ntp/packages

ntp/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: True
    - watch:
      - file: ntp/config

{% for _service in role.vars.service_blacklist %}
{% if salt['service.available'](_service) %}
ntp/service-blacklist/{{ _service }}:
  service.dead:
    - name: {{ _service|yaml_dquote }}
    - enable: False
{% endif %}
{% endfor %}
