{% set role = salt['ss.role']('knot') %}

include: {{ role.includes|yaml }}
