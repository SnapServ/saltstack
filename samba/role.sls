{% from slspath ~ '/init.sls' import role, account %}

samba/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}

samba/config:
  file.managed:
    - name: {{ role.vars.config_path|yaml_dquote }}
    - source: {{ role.tpl_path('smb.conf.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - check_cmd: {{ role.vars.testparm_cmd|yaml_dquote }}
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: samba/packages

{% for _service in role.vars.services %}
samba/services/{{ _service }}:
  service.running:
    - name: {{ _service|yaml_dquote }}
    - enable: True
    - watch:
      - file: samba/config
{% endfor %}

{% for _user, _password in role.vars.passwords|dictsort %}
samba/passwords/{{ _user }}:
  cmd.run:
    - name: {{ ('(echo "${PASSWORD}"; echo "${PASSWORD}") | smbpasswd -as ' ~ _user)|yaml_dquote }}
    - env:
        PASSWORD: {{ _password|yaml_dquote }}
    - require:
      - {{ account.resource('user', _user) }}
{% endfor %}
