{% set role = salt['ss.role']('prosody') %}
{% import role.dependency('software') as software %}{% set software = software %}

include: {{ role.includes|yaml }}
