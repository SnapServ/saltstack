{% set role = salt['ssx.role_data']('plexmediaserver') %}

{% if role.managed %}
include:
  - {{ sls }}.dependencies
  - {{ sls }}.role
{% endif %}
