{%- set locale = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, locale) }}

{%- if locale.managed %}
include:
  - .main
{%- endif %}
