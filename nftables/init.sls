{% set role = salt['ss.role']('nftables') %}

include: {{ role.includes|yaml }}
