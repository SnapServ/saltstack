{% from slspath ~ '/init.sls' import role %}

unattended-upgrades/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}

unattended-upgrades/config:
  file.managed:
    - name: {{ role.vars.config_path|yaml_dquote }}
    - source: {{ role.tpl_path('unattended-upgrades.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: unattended-upgrades/packages

unattended-upgrades/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: True
    - watch:
      - file: unattended-upgrades/config
