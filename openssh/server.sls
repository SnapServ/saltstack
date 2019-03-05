{% from slspath ~ '/init.sls' import role %}

openssh/packages:
  pkg.installed:
    - pkgs: {{ role.vars.server.packages|yaml }}

openssh/config:
  file.managed:
    - name: {{ role.vars.server.sshd_config_path|yaml_dquote }}
    - source: {{ role.tpl_path('sshd_config.j2')|yaml_dquote }}
    - check_cmd: {{ role.vars.server.sshd_config_check_cmd|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0640'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: openssh/packages

openssh/service:
  service.running:
    - name: {{ role.vars.server.service|yaml_dquote }}
    - enable: True
    - watch:
      - file: openssh/config
