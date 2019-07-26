{%- set mariadb = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, mariadb) }}

{%- if mariadb.managed %}
include:
  - .server
  - .databases
  - .users
{%- endif %}
