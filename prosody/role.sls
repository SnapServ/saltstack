{% from slspath ~ '/init.sls' import role %}

include:
  - .dependencies

prosody/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}
    - require:
      - custom: $system/repository/prosody

prosody/service:
  service.running:
    - name: {{ role.service|yaml_dquote }}
    - enable: True
    - require:
      - pkg: prosody/packages
