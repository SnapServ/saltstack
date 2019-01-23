{% set role = salt['custom.role_data']('certbot') %}

{% if role.managed %}
include:
  - .role
{% endif %}
