{% set role = salt['ss.role']('motd') %}

include: {{ role.includes|yaml }}
