{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import mariadb %}

mariadb/server/packages:
  pkg.installed:
    - pkgs: {{ mariadb.server.packages|yaml }}
    - reload_modules: True

mariadb/server/service:
  service.running:
    - name: {{ mariadb.server.service|yaml_dquote }}
    - enable: True
    - reload: True
    - require:
      - pkg: mariadb/server/packages
