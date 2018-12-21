{% set role = salt['ssx.role_data']('ntp') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
