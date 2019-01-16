{% set role = salt['ssx.role_data']('backupninja') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
