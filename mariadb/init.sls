{% set role = salt['custom.role_data']('mariadb') %}

{% if role.managed %}
include:
  - {{ sls }}.server
  - {{ sls }}.databases
  - {{ sls }}.users
{% endif %}
