{% set role = salt['ss.role']('quassel') %}
{% do role.add_include('core') %}

include: {{ role.includes|yaml }}
