{% set role = salt['ss.role']('mariadb') %}
{% do role.add_include('server') %}
{% do role.add_include('databases') %}
{% do role.add_include('users') %}

include: {{ role.includes|yaml }}
