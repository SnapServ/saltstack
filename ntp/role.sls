{% set role = salt['ssx.role_data']('ntp') %}

ntp/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}

ntp/config:
  file.managed:
    - name: {{ role.ntpconf_path|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/ntpconf.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        role: {{ role|yaml }}
    - require:
      - pkg: ntp/packages

ntp/service:
  service.running:
    - name: {{ role.service|yaml_dquote }}
    - enable: True
    - watch:
      - file: ntp/config
