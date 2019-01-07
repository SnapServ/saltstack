{% set role = salt['ssx.role_data']('grafana') %}

{% if role.managed %}
include:
  - {{ sls }}.dependencies
  - {{ sls }}.role
{% endif %}
