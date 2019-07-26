{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import samba %}

include:
  - account

samba/packages:
  pkg.installed:
    - pkgs: {{ samba.packages|yaml }}

samba/config:
  file.managed:
    - name: {{ samba.config_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['smb.conf.j2'],
        lookup='smb-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - check_cmd: {{ samba.testparm_cmd|yaml_dquote }}
    - context:
        samba: {{ samba|yaml }}
    - require:
      - pkg: samba/packages

{% for _service in samba.services %}
samba/services/{{ _service }}:
  service.running:
    - name: {{ _service|yaml_dquote }}
    - enable: True
    - watch:
      - file: samba/config
{% endfor %}

{% for _user, _password in samba.passwords|dictsort %}
samba/passwords/{{ _user }}:
  cmd.run:
    - name: {{ ('(echo "${PASSWORD}"; echo "${PASSWORD}") | smbpasswd -as ' ~ _user)|yaml_dquote }}
    - env:
        PASSWORD: {{ _password|yaml_dquote }}
    - require:
      - {{ stdlib.resource_dep('system-user', _user) }}
{% endfor %}
