{% set role = salt['ss.role']('ssl-cert') %}

{% if role.vars.managed %}
include:
  - .role
{% endif %}
