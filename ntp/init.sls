{%- set ntp = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, ntp) }}

{%- if ntp.managed %}
include:
  - .main
{%- endif %}
