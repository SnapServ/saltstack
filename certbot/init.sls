{% set role = salt['ss.role']('certbot') %}

include: {{ role.includes|yaml }}
