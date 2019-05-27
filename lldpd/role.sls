{% from slspath ~ '/init.sls' import role %}

lldpd/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}

lldpd/daemon-config:
  file.managed:
    - name: {{ role.vars.daemon_config_path }}
    - source: {{ role.tpl_path('daemon-config.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: lldpd/packages

lldpd/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: True
    - watch:
      - file: lldpd/daemon-config
