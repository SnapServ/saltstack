{%- set python = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, python) }}

{%- if python.managed %}
include:
  - .main
{%- endif %}
