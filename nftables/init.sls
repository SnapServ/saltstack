{% set role = salt['custom.role_data']('nftables') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
