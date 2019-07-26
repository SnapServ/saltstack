{%- set telegraf = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, telegraf) }}

{%- if telegraf.managed %}
include:
  - .main
{%- endif %}
