{%- set syncthing = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, syncthing) }}

{%- if syncthing.managed %}
include:
  - .global
  - .instances
{%- endif %}
