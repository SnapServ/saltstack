{% set role = salt['custom.role_data']('resolvconf') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
