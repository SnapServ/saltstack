{% set role = salt['ss.role']('locale') %}

include: {{ role.includes|yaml }}
