{% set role = salt['ss.role']('nginx') %}
{% do role.add_include('global') %}
{% do role.add_include('vhosts') %}

include: {{ role.includes|yaml }}
