{% set role = salt['ss.role']('docker') %}
{% import role.dependency('software') as software %}{% set software = software %}

include: {{ role.includes|yaml }}
