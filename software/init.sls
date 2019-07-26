{%- set software = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, software) }}

{%- if software.managed %}
include:
  - .repositories
  - .packages
{%- endif %}
