{% from slspath ~ '/init.sls' import role, account %}

acme-dns/install:
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
    - force: True
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - require:
      - file: acme-dns/install    

acme-dns/config:
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
      - archive: acme-dns/install

acme-dns/service:
  file.managed:
    - name: '/etc/systemd/system/acme-dns.service'
    - source: {{ role.tpl_path('acme-dns.service.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - archive: acme-dns/install

  module.run:
    - name: 'service.systemctl_reload'
    - onchanges:
      - file: acme-dns/service

  service.running:
    - name: 'acme-dns.service'
    - enable: True
    - require:
      - module: acme-dns/service
    - watch:
      - archive: acme-dns/install
      - file: acme-dns/service
      - file: acme-dns/config
