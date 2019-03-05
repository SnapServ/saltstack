{% set role = salt['ss.role']('mariadb') %}

{% if role.vars.managed %}
include:
  - {{ sls }}.server
  - {{ sls }}.databases
  - {{ sls }}.users

{% if salt['ss.role_active']('backupninja') %}
  - {{ sls }}.backupninja
{% endif %}
{% endif %}
