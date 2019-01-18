{% set role = salt['custom.role_data']('grafana') %}

{% if role.managed %}
include:
  - {{ sls }}.dependencies
  - {{ sls }}.role
{% endif %}
