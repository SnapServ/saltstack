{% set role = salt['ss.role']('python') %}

include: {{ role.includes|yaml }}
