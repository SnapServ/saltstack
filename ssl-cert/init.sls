{% set role = salt['ss.role']('ssl-cert') %}

include: {{ role.includes|yaml }}
