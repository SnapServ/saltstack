{% set role = salt['ss.role']('oauth2-proxy') %}
{% import role.dependency('account') as account %}{% set account = account %}

include: {{ role.includes|yaml }}
