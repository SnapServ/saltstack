{% set role = salt['custom.role_data']('timezone') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
