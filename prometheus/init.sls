{% set role = salt['ss.role']('prometheus') %}
{% import role.dependency('account') as account %}{% set account = account %}

{% do role.add_include('.server') %}
{% do role.add_include('.node_exporter') %}

include: {{ role.includes|yaml }}
