{% set role = salt['custom.role_data']('sudo') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
