{% set role = salt['ss.role']('plexmediaserver') %}
{% import role.dependency('software') as software %}{% set software = software %}

include: {{ role.includes|yaml }}
