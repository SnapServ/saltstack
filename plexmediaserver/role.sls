{% from slspath ~ '/init.sls' import role %}

include:
  - .dependencies

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
