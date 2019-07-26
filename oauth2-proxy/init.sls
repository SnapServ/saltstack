{%- set oauth2_proxy = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, oauth2_proxy) }}

{%- if oauth2_proxy.managed %}
include:
  - .main
{%- endif %}
