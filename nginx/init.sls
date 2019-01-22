{% set role = salt['custom.role_data']('nginx') %}

{% if role.managed %}
include:
  - .global
  - .vhosts
{% endif %}
