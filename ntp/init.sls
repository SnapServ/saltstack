{% set role = salt['custom.role_data']('ntp') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
