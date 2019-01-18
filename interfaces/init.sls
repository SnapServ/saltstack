{% set role = salt['custom.role_data']('interfaces') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
