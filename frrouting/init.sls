{% set role = salt['ss.role']('frrouting') %}
{% import role.dependency('software') as software %}{% set software = software %}

include: {{ role.includes|yaml }}
