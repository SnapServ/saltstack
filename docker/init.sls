{%- set docker = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, docker) }}

{%- if docker.managed %}
include:
  - .main
{%- endif %}
