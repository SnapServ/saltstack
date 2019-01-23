{% from slspath ~ '/init.sls' import role %}

include:
  - .dependencies

acme-dns/install:
  file.directory:
    - name: {{ role.service_dir|yaml_dquote }}
    - user: {{ role.service_user|yaml_dquote }}
    - group: {{ role.service_group|yaml_dquote }}
    - mode: '0750'
    - makedirs: True
    - require:
      - custom: $system/user/{{ role.service_user }}
      - custom: $system/group/{{ role.service_group }}

  archive.extracted:
    - name: {{ role.service_dir|yaml_dquote }}
    - source: {{ role.source_fmt.format(version=role.version, arch=role.arch)|yaml_dquote }}
    - source_hash: {{ role.source_hash_fmt.format(version=role.version, arch=role.arch)|yaml_dquote }}
    - source_hash_update: True
    - enforce_toplevel: False
    - force: True
    - user: {{ role.service_user|yaml_dquote }}
    - group: {{ role.service_group|yaml_dquote }}
    - require:
      - file: acme-dns/install    

acme-dns/config:
  file.managed:
    - name: {{ (role.service_dir ~ '/config.cfg')|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/config.cfg.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: {{ role.service_user|yaml_dquote }}
    - group: {{ role.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        role: {{ role|yaml }}
    - require:
      - archive: acme-dns/install

acme-dns/service:
  file.managed:
    - name: '/etc/systemd/system/acme-dns.service'
    - source: {{ ('salt://' ~ slspath ~ '/files/acme-dns.service.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        role: {{ role|yaml }}
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
