{% set role = salt['ssx.role_data']('syncthing') %}

syncthing/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}
    - require:
      - ssx: $system/repository/syncthing
