{%- set borgbackup = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, borgbackup) }}

{%- if borgbackup.managed %}
include:
  - .main
{%- endif %}
