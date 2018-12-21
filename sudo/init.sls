{% set role = salt['ssx.role_data']('sudo') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
