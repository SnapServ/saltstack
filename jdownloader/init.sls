{% set role = salt['ssx.role_data']('jdownloader') %}

{% if role.managed %}
include:
  - {{ sls }}.role
{% endif %}
