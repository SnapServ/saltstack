{%- set strongswan = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, strongswan) }}

{%- if strongswan.managed %}
include:
  - .main
{%- endif %}
