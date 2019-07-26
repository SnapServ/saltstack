{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import openssh %}

openssh/packages:
  pkg.installed:
    - pkgs: {{ openssh.server.packages|yaml }}

openssh/config:
  file.managed:
    - name: {{ openssh.server.sshd_config_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['sshd_config.j2'],
        lookup='sshd-config'
      ) }}
    - check_cmd: {{ openssh.server.sshd_config_check_cmd|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0640'
    - context:
        openssh: {{ openssh|yaml }}
    - require:
      - pkg: openssh/packages

openssh/service:
  service.running:
    - name: {{ openssh.server.service|yaml_dquote }}
    - enable: True
    - watch:
      - file: openssh/config
