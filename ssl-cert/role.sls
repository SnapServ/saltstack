{% from slspath ~ '/init.sls' import role %}

hosts/ssl-cert-snakeoil:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}

  cmd.run:
    - name: {{ role.snakeoil_regenerate_cmd|yaml_dquote }}
    - unless: {{ role.snakeoil_verify_cmd.format(
        certificate=role.snakeoil_certificate_path|quote,
      )|yaml_dquote }}
    - require:
      - pkg: hosts/ssl-cert-snakeoil
