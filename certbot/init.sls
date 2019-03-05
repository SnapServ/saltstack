{% set role = salt['ss.role']('certbot') %}

{% if role.vars.managed %}
include:
  - .role
{% endif %}
