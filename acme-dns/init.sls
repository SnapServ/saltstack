{% set role = salt['custom.role_data']('acme-dns') %}

{% if role.managed %}
include:
  - .dependencies
  - .role
{% endif %}
