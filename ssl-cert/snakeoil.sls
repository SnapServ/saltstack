{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import ssl_cert %}

ssl-cert/snakeoil:
  pkg.installed:
    - pkgs: {{ ssl_cert.snakeoil_packages|yaml }}

  cmd.run:
    - name: {{ ssl_cert.snakeoil_regenerate_cmd|yaml_dquote }}
    - unless: {{ ssl_cert.snakeoil_verify_cmd.format(
        certificate=ssl_cert.snakeoil_certificate_path|quote,
      )|yaml_dquote }}
    - require:
      - pkg: ssl-cert/snakeoil
