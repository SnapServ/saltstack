{%- set acme_dns = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, acme_dns) }}

{%- if acme_dns.managed %}
include:
  - .main
{%- endif %}
