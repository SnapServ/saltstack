{% from slspath ~ '/init.sls' import role %}

mariadb/server/packages:
  pkg.installed:
    - pkgs: {{ role.server.packages|yaml }}
    - reload_modules: True

mariadb/server/service:
  service.running:
    - name: {{ role.server.service|yaml_dquote }}
    - enable: True
    - reload: True
    - require:
      - pkg: mariadb/server/packages
