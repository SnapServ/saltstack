{% set role = salt['ss.role']('timezone') %}

include: {{ role.includes|yaml }}
