{% set role = salt['ssx.role_data']('unattended-upgrades') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
