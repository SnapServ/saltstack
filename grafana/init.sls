{%- set grafana = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, grafana) }}

{%- if grafana.managed %}
include:
  - .main
{%- endif %}
