{%- set timezone = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, timezone) }}

{%- if timezone.managed %}
include:
  - .main
{%- endif %}
