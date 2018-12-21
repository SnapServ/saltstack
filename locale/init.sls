{% set role = salt['ssx.role_data']('locale') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
