{% from slspath ~ '/init.sls' import role %}
{% set _install_path = role.base_path ~ '/' ~ 'node_exporter' %}

include:
  - .dependencies

prometheus/node_exporter/install:
  file.directory:
    - name: {{ _install_path|yaml_dquote }}
    - user: {{ role.service_user|yaml_dquote }}
    - group: {{ role.service_group|yaml_dquote }}
    - mode: '0750'
    - makedirs: True
    - require:
      - custom: $system/user/{{ role.service_user }}
      - custom: $system/group/{{ role.service_group }}

  archive.extracted:
    - name: {{ _install_path|yaml_dquote }}
    - source: {{ role.node_exporter.source_fmt.format(version=role.node_exporter.version, arch=role.arch)|yaml_dquote }}
    - source_hash: {{ role.node_exporter.source_hash_fmt.format(version=role.node_exporter.version, arch=role.arch)|yaml_dquote }}
    - source_hash_update: True
    - enforce_toplevel: False
    - user: {{ role.service_user|yaml_dquote }}
    - group: {{ role.service_group|yaml_dquote }}
    - options: '--strip-components=1'
    - list_options: '--strip-components=1'
    - require:
      - file: prometheus/node_exporter/install

prometheus/node_exporter/service:
  file.managed:
    - name: '/etc/systemd/system/prometheus-node-exporter.service'
    - source: {{ ('salt://' ~ slspath ~ '/files/exporter.service.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        install_path: {{ _install_path|yaml_dquote }}
        exporter_name: 'node'
        exporter_flags: {{ role.node_exporter.flags|yaml }}
        role: {{ role|yaml }}
    - require:
      - archive: prometheus/node_exporter/install

  module.run:
    - name: 'service.systemctl_reload'
    - onchanges:
      - file: prometheus/node_exporter/service

  service.running:
    - name: 'prometheus-node-exporter.service'
    - enable: True
    - require:
      - module: prometheus/node_exporter/service
    - watch:
      - file: prometheus/node_exporter/service
