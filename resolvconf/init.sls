{% set role = salt['ssx.role_data']('resolvconf') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
