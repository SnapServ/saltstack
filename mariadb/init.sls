{% set role = salt['custom.role_data']('mariadb') %}

{% if role.managed %}
include:
  - {{ sls }}.server
  - {{ sls }}.databases
  - {{ sls }}.users

{% if salt['custom.role_active']('backupninja') %}
  - {{ sls }}.backupninja
{% endif %}
{% endif %}
