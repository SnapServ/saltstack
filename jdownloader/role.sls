{% set role = salt['ssx.role_data']('jdownloader') %}

jdownloader/dependencies:
  pkg.installed:
    - pkgs: {{ role.dependencies|yaml }}

jdownloader/directory:
  file.directory:
    - name: {{ role.service_dir|yaml_dquote }}
    - user: {{ role.service_user|yaml_dquote }}
    - group: {{ role.service_group|yaml_dquote }}
    - mode: '0755'
    - makedirs: True
    - recurse:
      - 'user'
      - 'group'
    - require:
      - pkg: jdownloader/dependencies
      - ssx: $system/user/{{ role.service_user }}
      - ssx: $system/group/{{ role.service_group }}

jdownloader/install:
  file.managed:
    - name: {{ (role.service_dir ~ '/JDownloader.jar')|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/JDownloader.jar')|yaml_dquote }}
    - user: {{ role.service_user|yaml_dquote }}
    - group: {{ role.service_group|yaml_dquote }}
    - mode: '0644'
    - replace: False
    - require:
      - file: jdownloader/directory

{% if role.myjdownloader.email_address and role.myjdownloader.password %}
jdownloader/myjd-config:
  file.managed:
    - name: {{ (role.service_dir ~ 'cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json')|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/myjd.json.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: {{ role.service_user|yaml_dquote }}
    - group: {{ role.service_group|yaml_dquote }}
    - mode: '0640'
    - dir_mode: 0755
    - makedirs: True
    - replace: False
    - context:
        role: {{ role|yaml }}
    - require:
      - file: jdownloader/install
    - require_in:
      - service: jdownloader/service
{% endif %}

jdownloader/service:
  file.managed:
    - name: '/etc/systemd/system/jdownloader.service'
    - source: {{ ('salt://' ~ slspath ~ '/files/jdownloader.service.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        role: {{ role|yaml }}
    - require:
      - file: jdownloader/install

  module.run:
    - name: 'service.systemctl_reload'
    - onchanges:
      - file: jdownloader/service

  service.running:
    - name: 'jdownloader.service'
    - enable: True
    - require:
      - module: jdownloader/service
