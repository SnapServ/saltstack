{% set role = salt['ss.role']('grub') %}

include: {{ role.includes|yaml }}
