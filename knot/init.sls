{%- set knot = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, knot) }}

{%- if knot.managed %}
include:
  - .main
{%- endif %}
