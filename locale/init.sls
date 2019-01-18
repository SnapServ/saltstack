{% set role = salt['custom.role_data']('locale') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
