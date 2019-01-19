{% set role = salt['custom.role_data']('grafana') %}

grafana/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}
    - require:
      - custom: $system/repository/grafana

grafana/service:
  service.running:
    - name: {{ role.service|yaml_dquote }}
    - enable: True
    - reload: True
    - require:
      - pkg: grafana/packages
