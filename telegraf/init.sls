{% set role = salt['ss.role']('telegraf') %}
{% import role.dependency('software') as software %}{% set software = software %}

include: {{ role.includes|yaml }}
