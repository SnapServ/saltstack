{% set role = salt['ss.role']('grafana') %}
{% import role.dependency('software') as software %}{% set software = software %}

include: {{ role.includes|yaml }}
