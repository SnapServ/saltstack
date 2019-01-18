{% set role = salt['custom.role_data']('jdownloader') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
