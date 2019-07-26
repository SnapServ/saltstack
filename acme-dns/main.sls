{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import acme_dns %}

include:
  - account

acme-dns/install:
  file.directory:
    - name: {{ acme_dns.service_dir|yaml_dquote }}
    - user: {{ acme_dns.service_user|yaml_dquote }}
    - group: {{ acme_dns.service_group|yaml_dquote }}
    - mode: '0750'
    - makedirs: True
    - require:
      - {{ stdlib.resource_dep('system-user', acme_dns.service_user) }}
      - {{ stdlib.resource_dep('system-group', acme_dns.service_group) }}

  archive.extracted:
    - name: {{ acme_dns.service_dir|yaml_dquote }}
    - source: {{ acme_dns.source_fmt.format(
        version=acme_dns.version,
        arch=acme_dns.version_arch or grains['osarch'],
      )|yaml_dquote }}
    - source_hash: {{ acme_dns.source_hash_fmt.format(
        version=acme_dns.version,
        arch=acme_dns.version_arch or grains['osarch'],
      )|yaml_dquote }}
    - source_hash_update: True
    - enforce_toplevel: False
    - force: True
    - user: {{ acme_dns.service_user|yaml_dquote }}
    - group: {{ acme_dns.service_group|yaml_dquote }}
    - require:
      - file: acme-dns/install    

acme-dns/config:
  file.managed:
    - name: {{ (acme_dns.service_dir ~ '/config.cfg')|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['config.cfg.j2'],
        lookup='acme-dns-config'
      ) }}
    - template: 'jinja'
    - user: {{ acme_dns.service_user|yaml_dquote }}
    - group: {{ acme_dns.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        acme_dns: {{ acme_dns|yaml }}
    - require:
      - archive: acme-dns/install

acme-dns/service:
  file.managed:
    - name: '/etc/systemd/system/acme-dns.service'
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['acme-dns.service.j2'],
        lookup='acme-dns-service-unit'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        acme_dns: {{ acme_dns|yaml }}
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
