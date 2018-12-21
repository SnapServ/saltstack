{% set role = salt['ssx.role_data']('openssh') %}

{% if role.managed %}
include:
  - {{ sls }}.server
{% endif %}
