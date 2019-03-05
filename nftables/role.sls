{% from slspath ~ '/init.sls' import role %}

nftables/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}

nftables/ruleset:
  file.managed:
    - name: {{ role.vars.ruleset_path|yaml_dquote }}
    - source: {{ role.tpl_path('salt.ruleset.j2')|yaml_dquote }}
    - check_cmd: {{ role.vars.ruleset_check_cmd|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0640'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: nftables/packages

nftables/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: True
    - watch:
      - file: nftables/ruleset
