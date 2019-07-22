{% set role = salt['ss.role']('foreman') %}
{% import role.dependency('software') as software %}{% set software = software %}

include: {{ role.includes|yaml }}
