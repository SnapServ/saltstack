{% set role = salt['custom.role_data']('prometheus') %}

include:
  - account
