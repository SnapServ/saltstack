{%- set nginx = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, nginx) }}

{%- if nginx.managed %}
include:
  - .global
  - .vhosts
{%- endif %}
