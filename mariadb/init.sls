{% set role = salt['custom.role_data']('mariadb') %}

{% if role.managed %}
include:
  - {{ sls }}.server
  - {{ sls }}.databases
  - {{ sls }}.users

{% if salt['custom.role_data']('backupninja').get('managed', False) %}
  - {{ sls }}.backupninja
{% endif %}
{% endif %}
