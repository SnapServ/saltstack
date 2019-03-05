{% set role = salt['ss.role']('incron') %}

include: {{ role.includes|yaml }}
