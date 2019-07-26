{%- set motd = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, motd) }}

{%- if motd.managed %}
include:
  - .main
{%- endif %}
