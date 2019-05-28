{% from slspath ~ '/init.sls' import role, account %}

oauth2-proxy/install:
  file.directory:
    - name: {{ role.vars.service_dir|yaml_dquote }}
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - mode: '0750'
    - makedirs: True
    - require:
      - {{ account.role.resource('user', role.vars.service_user) }}
      - {{ account.role.resource('group', role.vars.service_group) }}

  archive.extracted:
    - name: {{ role.vars.service_dir|yaml_dquote }}
    - source: {{ role.vars.source_fmt.format(version=role.vars.version, arch=role.vars.arch)|yaml_dquote }}
    - source_hash: {{ role.vars.source_hash_fmt.format(version=role.vars.version, arch=role.vars.arch)|yaml_dquote }}
    - source_hash_update: True
    - enforce_toplevel: False
    - options: '--strip-components=1'
    - force: True
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - require:
      - file: oauth2-proxy/install    

oauth2-proxy/config:
  file.managed:
    - name: {{ (role.vars.service_dir ~ '/config.cfg')|yaml_dquote }}
    - source: {{ role.tpl_path('config.cfg.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - archive: oauth2-proxy/install

oauth2-proxy/portal/static-files:
  file.recurse:
    - name: {{ role.vars.static_files_dir|yaml_dquote }}
    - source: {{ role.tpl_path('portal-static/')|yaml_dquote }}
    - user: 'root'
    - group: {{ role.vars.service_group|yaml_dquote }}
    - file_mode: '0640'
    - file_mode: '0750'
    - exclude_pat: 'settings.json'
    - clean: True
    - require:
        - archive: oauth2-proxy/install

oauth2-proxy/portal/settings:
  file.managed:
    - name: {{ (role.vars.static_files_dir ~ '/settings.json')|yaml_dquote }}
    - source: {{ role.tpl_path('portal-settings.json.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: {{ role.vars.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - archive: oauth2-proxy/install

oauth2-proxy/service:
  file.managed:
    - name: '/etc/systemd/system/oauth2-proxy.service'
    - source: {{ role.tpl_path('oauth2-proxy.service.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        vars: {{ role.vars|yaml }}
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
