{%- set jdownloader = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, jdownloader) }}

{%- if jdownloader.managed %}
include:
  - .main
{%- endif %}
