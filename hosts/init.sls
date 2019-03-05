{% set role = salt['ss.role']('hosts') %}

include: {{ role.includes|yaml }}
