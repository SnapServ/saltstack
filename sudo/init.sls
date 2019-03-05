{% set role = salt['ss.role']('sudo') %}

include: {{ role.includes|yaml }}
