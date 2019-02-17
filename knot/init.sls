{% set role = salt['custom.role_data']('knot') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
