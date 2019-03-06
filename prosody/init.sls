{% set role = salt['ss.role']('prosody') %}

include: {{ role.includes|yaml }}
