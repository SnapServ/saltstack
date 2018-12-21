{% set role = salt['ssx.role_data']('samba') %}

samba/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}

samba/config:
  file.managed:
    - name: {{ role.config_path|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/smb.conf.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - check_cmd: {{ role.testparm_cmd|yaml_dquote }}
    - context:
        role: {{ role|yaml }}
    - require:
      - pkg: samba/packages

{% for _service in role.services %}
samba/services/{{ _service }}:
  service.running:
    - name: {{ _service|yaml_dquote }}
    - enable: True
    - watch:
      - file: samba/config
{% endfor %}

{% for _user, _password in role.passwords|dictsort %}
samba/passwords/{{ _user }}:
  cmd.run:
    - name: {{ ('(echo "${PASSWORD}"; echo "${PASSWORD}") | smbpasswd -as ' ~ _user)|yaml_dquote }}
    - env:
        PASSWORD: {{ _password|yaml_dquote }}
    - require:
      - ssx: $system/user/{{ _user }}
{% endfor %}
