{%- set resolvconf = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, resolvconf) }}

{%- if resolvconf.managed %}
include:
  - .main
{%- endif %}
