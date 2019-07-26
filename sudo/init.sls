{%- set sudo = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, sudo) }}

{%- if sudo.managed %}
include:
  - .main
{%- endif %}
