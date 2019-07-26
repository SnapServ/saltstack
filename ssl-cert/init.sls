{%- set ssl_cert = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, ssl_cert) }}

{%- if ssl_cert.managed %}
include:
  - .snakeoil
  {%- if ssl_cert.certificates.keys()|count > 0 %}
  - .acmesh
  - .certificates
  {%- endif %}
{%- endif %}
