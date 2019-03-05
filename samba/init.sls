{% set role = salt['ss.role']('samba') %}
{% import role.dependency('account') as account %}{% set account = account %}

include: {{ role.includes|yaml }}
