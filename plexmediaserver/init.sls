{%- set plexmediaserver = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, plexmediaserver) }}

{%- if plexmediaserver.managed %}
include:
  - .main
{%- endif %}
