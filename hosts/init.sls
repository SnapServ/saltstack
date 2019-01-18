{% set role = salt['custom.role_data']('hosts') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
