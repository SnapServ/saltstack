{% set role = salt['ss.role']('jdownloader') %}
{% import role.dependency('account') as account %}{% set account = account %}

include: {{ role.includes|yaml }}
