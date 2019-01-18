{% set role = salt['custom.role_data']('openssh') %}

{% if role.managed %}
include:
  - {{ sls }}.server
{% endif %}
