{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import oauth2_proxy %}

include:
  - account

{%- set _version_arch = oauth2_proxy.version_arch or grains['osarch'] %}

oauth2-proxy/install:
  file.directory:
    - name: {{ oauth2_proxy.service_dir|yaml_dquote }}
    - user: {{ oauth2_proxy.service_user|yaml_dquote }}
    - group: {{ oauth2_proxy.service_group|yaml_dquote }}
    - mode: '0750'
    - makedirs: True
    - require:
      - {{ stdlib.resource_dep('system-user', oauth2_proxy.service_user) }}
      - {{ stdlib.resource_dep('system-group', oauth2_proxy.service_group) }}

  archive.extracted:
    - name: {{ oauth2_proxy.service_dir|yaml_dquote }}
    - source: {{ oauth2_proxy.source_fmt.format(
        version=oauth2_proxy.version,
        arch=_version_arch,
      )|yaml_dquote }}
    - source_hash: {{ oauth2_proxy.source_hash_fmt.format(
        version=oauth2_proxy.version,
        arch=_version_arch,
      )|yaml_dquote }}
    - source_hash_update: True
    - enforce_toplevel: False
    - options: '--strip-components=1'
    - force: True
    - user: {{ oauth2_proxy.service_user|yaml_dquote }}
    - group: {{ oauth2_proxy.service_group|yaml_dquote }}
    - require:
      - file: oauth2-proxy/install    

oauth2-proxy/config:
  file.managed:
    - name: {{ (oauth2_proxy.service_dir ~ '/config.cfg')|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['config.cfg.j2'],
        lookup='oauth2-proxy-config'
      ) }}
    - template: 'jinja'
    - user: {{ oauth2_proxy.service_user|yaml_dquote }}
    - group: {{ oauth2_proxy.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        oauth2_proxy: {{ oauth2_proxy|yaml }}
    - require:
      - archive: oauth2-proxy/install

oauth2-proxy/authenticated-emails:
  file.managed:
    - name: {{ (oauth2_proxy.service_dir ~ '/authenticated-emails')|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['authenticated-emails.j2'],
        lookup='authenticated-emails-config'
      ) }}
    - template: 'jinja'
    - user: {{ oauth2_proxy.service_user|yaml_dquote }}
    - group: {{ oauth2_proxy.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        oauth2_proxy: {{ oauth2_proxy|yaml }}
    - require:
      - archive: oauth2-proxy/install

oauth2-proxy/portal/static-files:
  file.recurse:
    - name: {{ oauth2_proxy.static_files_dir|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['portal-static/'],
        lookup='portal-static-dir'
      ) }}
    - user: 'root'
    - group: {{ oauth2_proxy.service_group|yaml_dquote }}
    - file_mode: '0640'
    - file_mode: '0750'
    - exclude_pat: 'settings.json'
    - clean: True
    - require:
        - archive: oauth2-proxy/install

oauth2-proxy/portal/settings:
  file.managed:
    - name: {{ (oauth2_proxy.static_files_dir ~ '/settings.json')|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['portal-settings.json.j2'],
        lookup='portal-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: {{ oauth2_proxy.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        oauth2_proxy: {{ oauth2_proxy|yaml }}
    - require:
      - archive: oauth2-proxy/install

oauth2-proxy/service:
  file.managed:
    - name: '/etc/systemd/system/oauth2-proxy.service'
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['oauth2-proxy.service.j2'],
        lookup='oauth2-proxy-service-unit'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        oauth2_proxy: {{ oauth2_proxy|yaml }}
        version_arch: {{ _version_arch|yaml_encode }}
    - require:
      - archive: oauth2-proxy/install

  module.run:
    - name: 'service.systemctl_reload'
    - onchanges:
      - file: oauth2-proxy/service

  service.running:
    - name: 'oauth2-proxy.service'
    - enable: True
    - require:
      - module: oauth2-proxy/service
    - watch:
      - archive: oauth2-proxy/install
      - file: oauth2-proxy/service
      - file: oauth2-proxy/config
