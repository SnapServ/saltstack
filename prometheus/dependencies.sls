{% set role = salt['ssx.role_data']('prometheus') %}

include:
  - account
