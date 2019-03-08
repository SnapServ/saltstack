{% set role = salt['ss.role']('influxdb') %}
{% import role.dependency('software') as software %}{% set software = software %}

include: {{ role.includes|yaml }}
