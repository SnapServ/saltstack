{% set role = salt['ssx.role_data']('syncthing') %}

{% if role.managed %}
include:
  - {{ sls }}.dependencies
  - {{ sls }}.global
  - {{ sls }}.instances
{% endif %}
