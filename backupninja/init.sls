{% set role = salt['custom.role_data']('backupninja') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
