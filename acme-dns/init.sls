{% set role = salt['ss.role']('acme-dns') %}
{% import role.dependency('account') as account %}{% set account = account %}

include: {{ role.includes|yaml }}
