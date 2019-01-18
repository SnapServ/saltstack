{% set role = salt['custom.role_data']('samba') %}

include:
  - account
