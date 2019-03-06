{% set role = salt['ss.role']('account') %}
{% do role.add_include('groups') %}
{% do role.add_include('users') %}
{% do role.add_include('sshkeys') %}

include: {{ role.includes|yaml }}
