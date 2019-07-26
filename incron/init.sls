{%- set incron = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, incron) }}

{%- if incron.managed %}
include:
  - .main
{%- endif %}
