{% set role = salt['ss.role']('lldpd') %}

include: {{ role.includes|yaml }}
