{%- set openssh = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, openssh) }}

{%- if openssh.managed %}
include:
  - .server
{%- endif %}
