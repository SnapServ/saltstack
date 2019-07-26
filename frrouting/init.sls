{%- set frrouting = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, frrouting) }}

{%- if frrouting.managed %}
include:
  - .main
{%- endif %}
