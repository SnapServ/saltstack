{% set role = salt['ss.role']('ssl-cert') %}
{% import role.dependency('account') as account %}{% set account = account %}

include: {{ role.includes|yaml }}
