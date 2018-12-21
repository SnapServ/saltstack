{% set role = salt['ssx.role_data']('motd') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
