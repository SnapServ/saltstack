{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import jdownloader %}

include:
  - account

jdownloader/dependencies:
  pkg.installed:
    - pkgs: {{ jdownloader.dependencies|yaml }}

jdownloader/directory:
  file.directory:
    - name: {{ jdownloader.service_dir|yaml_dquote }}
    - user: {{ jdownloader.service_user|yaml_dquote }}
    - group: {{ jdownloader.service_group|yaml_dquote }}
    - mode: '0755'
    - makedirs: True
    - recurse:
      - 'user'
      - 'group'
    - require:
      - pkg: jdownloader/dependencies
      - {{ stdlib.resource_dep('system-user', jdownloader.service_user) }}
      - {{ stdlib.resource_dep('system-group', jdownloader.service_group) }}

jdownloader/install:
  file.managed:
    - name: {{ (jdownloader.service_dir ~ '/JDownloader.jar')|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['JDownloader.jar'],
        lookup='jdownloader-binary'
      ) }}
    - user: {{ jdownloader.service_user|yaml_dquote }}
    - group: {{ jdownloader.service_group|yaml_dquote }}
    - mode: '0644'
    - replace: False
    - require:
      - file: jdownloader/directory

{% if jdownloader.myjdownloader.email_address and jdownloader.myjdownloader.password %}
jdownloader/myjd-config:
  file.managed:
    - name: {{ (jdownloader.service_dir ~ 'cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json')|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['myjd.json.j2'],
        lookup='my-jdownloader-config'
      ) }}
    - template: 'jinja'
    - user: {{ jdownloader.service_user|yaml_dquote }}
    - group: {{ jdownloader.service_group|yaml_dquote }}
    - mode: '0640'
    - dir_mode: 0755
    - makedirs: True
    - replace: False
    - context:
        jdownloader: {{ jdownloader|yaml }}
    - require:
      - file: jdownloader/install
    - require_in:
      - service: jdownloader/service
{% endif %}

jdownloader/service:
  file.managed:
    - name: '/etc/systemd/system/jdownloader.service'
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['jdownloader.service.j2'],
        lookup='jdownloader-service-unit'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        jdownloader: {{ jdownloader|yaml }}
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
