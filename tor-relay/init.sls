{% set role = salt['ss.role']('tor-relay') %}

include: {{ role.includes|yaml }}
