{% set role = salt['ss.role']('interfaces') %}

include: {{ role.includes|yaml }}
