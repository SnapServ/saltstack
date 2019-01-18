{% set role = salt['custom.role_data']('motd') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
