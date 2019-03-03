{% set role = salt['custom.role']('python') %}

include: {{ role.includes|yaml }}
