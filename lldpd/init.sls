{%- set lldpd = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, lldpd) }}

{%- if lldpd.managed %}
include:
  - .main
{%- endif %}
