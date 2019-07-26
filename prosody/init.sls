{%- set prosody = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, prosody) }}

{%- if prosody.managed %}
include:
  - .main
{%- endif %}
