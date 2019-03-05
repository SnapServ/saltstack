{% set role = salt['ss.role']('prosody') %}

{% if role.vars.managed %}
include:
  - {{ sls }}.dependencies
  - {{ sls }}.role
{% endif %}
