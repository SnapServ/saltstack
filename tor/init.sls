{%- set tor = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, tor) }}

{%- if tor.managed %}
include:
  - .main
{%- endif %}
