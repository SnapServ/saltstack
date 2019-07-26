{%- set unattended_upgrades = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, unattended_upgrades) }}

{%- if unattended_upgrades.managed %}
include:
  - .main
{%- endif %}
