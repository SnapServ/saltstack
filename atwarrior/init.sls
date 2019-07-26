{%- set atwarrior = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, atwarrior) }}

{%- if atwarrior.managed %}
include:
  - .main
{%- endif %}
