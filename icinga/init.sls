{%- set icinga = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, icinga) }}

{%- if not icinga.master_fqdn %}
  {{- salt['test.exception']('icinga.master_fqdn must be configured') }}
{%- endif %}

{%- if icinga.managed %}
include:
  {%- if grains['fqdn'] == icinga.master_fqdn %}
  - .master
  {%- else %}
  - .client
  {%- endif %}
{%- endif %}
