{%- set quassel = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, quassel) }}

{%- if quassel.managed %}
include:
  - .core
{%- endif %}
