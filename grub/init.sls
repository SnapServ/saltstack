{%- set grub = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, grub) }}

{%- if grub.managed %}
include:
  - .main
{%- endif %}
