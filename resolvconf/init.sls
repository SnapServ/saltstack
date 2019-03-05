{% set role = salt['ss.role']('resolvconf') %}

include: {{ role.includes|yaml }}
