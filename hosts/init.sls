{%- set hosts = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, hosts) }}

{%- if hosts.managed %}
include:
  - .main
{%- endif %}
