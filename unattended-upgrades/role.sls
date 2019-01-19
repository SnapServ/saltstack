{% from slspath ~ '/init.sls' import role %}

unattended-upgrades/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}

unattended-upgrades/config:
  file.managed:
    - name: {{ role.config_path|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/unattended-upgrades.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        role: {{ role|yaml }}
    - require:
      - pkg: unattended-upgrades/packages

unattended-upgrades/service:
  service.running:
    - name: {{ role.service|yaml_dquote }}
    - enable: True
    - watch:
      - file: unattended-upgrades/config
