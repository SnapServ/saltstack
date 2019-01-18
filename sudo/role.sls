{% set role = salt['custom.role_data']('sudo') %}

sudo/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}

sudo/config:
  file.managed:
    - name: {{ role.sudoers_path|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/sudoers.j2')|yaml_dquote }}
    - check_cmd: {{ role.sudoers_check_cmd|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0640'
    - context:
        role: {{ role|yaml }}
    - require:
      - pkg: sudo/packages
