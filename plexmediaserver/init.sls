{% set role = salt['custom.role_data']('plexmediaserver') %}

{% if role.managed %}
include:
  - {{ sls }}.dependencies
  - {{ sls }}.role
{% endif %}
