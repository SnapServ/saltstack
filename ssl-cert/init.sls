{% set role = salt['custom.role_data']('ssl-cert') %}

{% if role.managed %}
include:
  - .role
{% endif %}
