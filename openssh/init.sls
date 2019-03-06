{% set role = salt['ss.role']('openssh') %}
{% do role.add_include('server') %}

include: {{ role.includes|yaml }}
