{% set role = salt['ssx.role_data']('timezone') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
