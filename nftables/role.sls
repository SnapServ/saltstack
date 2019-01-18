{% set role = salt['custom.role_data']('nftables') %}

nftables/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}

nftables/ruleset:
  file.managed:
    - name: {{ role.ruleset_path|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/salt.ruleset.j2')|yaml_dquote }}
    - check_cmd: {{ role.ruleset_check_cmd|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0640'
    - context:
        role: {{ role|yaml }}
    - require:
      - pkg: nftables/packages

nftables/service:
  service.running:
    - name: {{ role.service|yaml_dquote }}
    - enable: True
    - watch:
      - file: nftables/ruleset
