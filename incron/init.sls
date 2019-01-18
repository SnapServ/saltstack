{% set role = salt['custom.role_data']('incron') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
