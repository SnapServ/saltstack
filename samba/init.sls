{% set role = salt['ssx.role_data']('samba') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
