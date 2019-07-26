{% from slspath ~ '/init.sls' import role, account %}
{% set _install_path = role.vars.base_path ~ '/' ~ 'node_exporter' %}

include:
  - .dependencies

prometheus/node_exporter/install:
  file.directory:
    - name: {{ _install_path|yaml_dquote }}
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - mode: '0750'
    - makedirs: True
    - require:
      - {{ account.resource('user', role.vars.service_user) }}
      - {{ account.resource('group', role.vars.service_group) }}

  archive.extracted:
    - name: {{ _install_path|yaml_dquote }}
    - source: {{ role.vars.node_exporter.source_fmt.format(version=role.vars.node_exporter.version, arch=role.vars.arch)|yaml_dquote }}
    - source_hash: {{ role.vars.node_exporter.source_hash_fmt.format(version=role.vars.node_exporter.version, arch=role.vars.arch)|yaml_dquote }}
    - source_hash_update: True
    - enforce_toplevel: False
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - options: '--strip-components=1'
    - list_options: '--strip-components=1'
    - require:
      - file: prometheus/node_exporter/install

prometheus/node_exporter/service:
  file.managed:
    - name: '/etc/systemd/system/prometheus-node-exporter.service'
    - source: {{ role.tpl_path('exporter.service.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        install_path: {{ _install_path|yaml_dquote }}
        exporter_name: 'node'
        exporter_flags: {{ role.vars.node_exporter.flags|yaml }}
        vars: {{ role.vars|yaml }}
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
