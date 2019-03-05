{% from slspath ~ '/init.sls' import role %}

sudo/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}

sudo/config:
  file.managed:
    - name: {{ role.vars.sudoers_path|yaml_dquote }}
    - source: {{ role.tpl_path('sudoers.j2')|yaml_dquote }}
    - check_cmd: {{ role.vars.sudoers_check_cmd|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0640'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: sudo/packages
