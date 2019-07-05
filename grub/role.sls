{% from slspath ~ '/init.sls' import role %}

grub/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}

grub/defaults-strip:
  file.replace:
    - name: {{ role.vars.defaults_config|yaml_dquote }}
    - pattern: '(^|(?<=\n))\s*(#.*?)([\r\n]{1,2}|$)'
    - repl: ''
    - flags: 0
    - backslash_literal: true
    - require:
      - pkg: grub/packages
    - onchanges_in:
      - cmd: grub/regenerate-config

{% for _key, _value in role.vars.defaults|dictsort %}
{% set _key = _key.strip().upper() %}

grub/defaults/{{ _key }}:
  file.replace:
    - name: {{ role.vars.defaults_config|yaml_dquote }}
    - pattern: {{ ('^\s*' ~ _key ~ '=.*$')|yaml_dquote }}
    - repl: {{ (_key ~ '=' ~ _value|quote)|yaml_dquote }}
    - append_if_not_found: true
    - require:
      - pkg: grub/packages
      - file: grub/defaults-strip
    - onchanges_in:
      - cmd: grub/regenerate-config

{% endfor %}

grub/regenerate-config:
  cmd.run:
    - name: {{ role.vars.regenerate_config_cmd|yaml_dquote }}
    - runas: 'root'
