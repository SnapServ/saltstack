{% set role = salt['ss.role']('nginx') %}

{% if role.vars.managed %}
include:
  - .global
  - .vhosts
{% endif %}
