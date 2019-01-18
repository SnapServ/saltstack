{% set role = salt['custom.role_data']('unattended-upgrades') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
