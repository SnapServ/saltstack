{%- set nftables = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, nftables) }}

{%- if nftables.managed %}
include:
  - .main
{%- endif %}
