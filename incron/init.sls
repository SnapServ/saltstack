{% set role = salt['ssx.role_data']('incron') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
