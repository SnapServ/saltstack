{%- set interfaces = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, interfaces) }}

{%- if interfaces.managed %}
include:
  - .main
{%- endif %}
