{% set role = salt['ss.role']('software') %}
{% do role.add_include('repositories') %}
{% do role.add_include('packages') %}

include: {{ role.includes|yaml }}
