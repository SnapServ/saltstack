{% set role = salt['ss.role']('openssh') %}

{% if role.vars.managed %}
include:
  - {{ sls }}.server
{% endif %}
