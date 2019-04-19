{% from slspath ~ '/init.sls' import role %}

ssl-cert/snakeoil:
  pkg.installed:
    - pkgs: {{ role.vars.snakeoil_packages|yaml }}

  cmd.run:
    - name: {{ role.vars.snakeoil_regenerate_cmd|yaml_dquote }}
    - unless: {{ role.vars.snakeoil_verify_cmd.format(
        certificate=role.vars.snakeoil_certificate_path|quote,
      )|yaml_dquote }}
    - require:
      - pkg: ssl-cert/snakeoil
