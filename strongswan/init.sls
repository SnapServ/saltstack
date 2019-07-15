{% set role = salt['ss.role']('strongswan') %}

include: {{ role.includes|yaml }}
