{% set role = salt['custom.role_data']('plexmediaserver') %}

plexmediaserver/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}
    - require:
      - custom: $system/repository/plexmediaserver

plexmediaserver/service:
  service.running:
    - name: {{ role.service|yaml_dquote }}
    - enable: True
    - require:
      - pkg: plexmediaserver/packages
