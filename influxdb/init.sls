{%- set influxdb = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, influxdb) }}

{%- if influxdb.managed %}
include:
  - .main
{%- endif %}
