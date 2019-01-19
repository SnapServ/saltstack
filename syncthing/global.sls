{% set role = salt['custom.role_data']('syncthing') %}

syncthing/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}
    - require:
      - custom: $system/repository/syncthing
