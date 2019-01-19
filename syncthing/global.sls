{% from slspath ~ '/init.sls' import role %}

include:
  - .dependencies

syncthing/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}
    - require:
      - custom: $system/repository/syncthing
