{% set role = salt['ss.role']('ntp') %}

include: {{ role.includes|yaml }}
