{% set role = salt['ssx.role_data']('nftables') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
