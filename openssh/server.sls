{% set role = salt['ssx.role_data']('openssh') %}

openssh/packages:
  pkg.installed:
    - pkgs: {{ role.server.packages|yaml }}

openssh/config:
  file.managed:
    - name: {{ role.server.sshd_config_path|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/sshd_config.j2')|yaml_dquote }}
    - check_cmd: {{ role.server.sshd_config_check_cmd|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0640'
    - context:
        role: {{ role|yaml }}
    - require:
      - pkg: openssh/packages

openssh/service:
  service.running:
    - name: {{ role.server.service|yaml_dquote }}
    - enable: True
    - watch:
      - file: openssh/config
