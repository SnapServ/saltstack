{% set role = salt['custom.role_data']('prosody') %}

{% if role.managed %}
include:
  - {{ sls }}.dependencies
  - {{ sls }}.role
{% endif %}
