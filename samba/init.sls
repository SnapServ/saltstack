{%- set samba = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, samba) }}

{%- if samba.managed %}
include:
  - .main
{%- endif %}
