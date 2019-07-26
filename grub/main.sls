{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import grub %}

grub/packages:
  pkg.installed:
    - pkgs: {{ grub.packages|yaml }}

grub/strip-defaults:
  file.replace:
    - name: {{ grub.defaults_config|yaml_dquote }}
    - pattern: '(^|(?<=\\n))\\s*(#.*?)([\\r\\n]{1,2}|$)'
    - repl: ''
    - flags: 0
    - require:
      - pkg: grub/packages
    - onchanges_in:
      - cmd: grub/update-config

{% for _key, _value in grub.defaults|dictsort %}
{% set _key = _key.strip().upper() %}

grub/defaults/{{ _key }}:
  file.replace:
    - name: {{ grub.defaults_config|yaml_dquote }}
    - pattern: {{ ('^\s*' ~ _key ~ '=.*$')|yaml_dquote }}
    - repl: {{ (_key ~ '=' ~ _value|quote)|yaml_dquote }}
    - append_if_not_found: True
    - require:
      - pkg: grub/packages
      - file: grub/strip-defaults
    - onchanges_in:
      - cmd: grub/update-config

{% endfor %}

grub/update-config:
  cmd.run:
    - name: {{ grub.update_config_cmd|yaml_dquote }}
    - runas: 'root'
