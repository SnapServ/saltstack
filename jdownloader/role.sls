{% from slspath ~ '/init.sls' import role, account %}

jdownloader/dependencies:
  pkg.installed:
    - pkgs: {{ role.vars.dependencies|yaml }}

jdownloader/directory:
  file.directory:
    - name: {{ role.vars.service_dir|yaml_dquote }}
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - mode: '0755'
    - makedirs: True
    - recurse:
      - 'user'
      - 'group'
    - require:
      - pkg: jdownloader/dependencies
      - {{ account.role.resource('user', role.vars.service_user) }}
      - {{ account.role.resource('group', role.vars.service_group) }}

jdownloader/install:
  file.managed:
    - name: {{ (role.vars.service_dir ~ '/JDownloader.jar')|yaml_dquote }}
    - source: {{ role.tpl_path('JDownloader.jar')|yaml_dquote }}
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - mode: '0644'
    - replace: False
    - require:
      - file: jdownloader/directory

{% if role.vars.myjdownloader.email_address and role.vars.myjdownloader.password %}
jdownloader/myjd-config:
  file.managed:
    - name: {{ (role.vars.service_dir ~ 'cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json')|yaml_dquote }}
    - source: {{ role.tpl_path('myjd.json.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - mode: '0640'
    - dir_mode: 0755
    - makedirs: True
    - replace: False
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - file: jdownloader/install
    - require_in:
      - service: jdownloader/service
{% endif %}

jdownloader/service:
  file.managed:
    - name: '/etc/systemd/system/jdownloader.service'
    - source: {{ role.tpl_path('jdownloader.service.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        vars: {{ role.vars|yaml }}
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
