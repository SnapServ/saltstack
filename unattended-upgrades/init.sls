{% set role = salt['ss.role']('unattended-upgrades') %}

include: {{ role.includes|yaml }}
