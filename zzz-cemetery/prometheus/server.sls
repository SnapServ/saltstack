{% from slspath ~ '/init.sls' import role, account %}
{% set _install_path = role.vars.base_path ~ '/' ~ 'server' %}

prometheus/server/install:
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
    - source: {{ role.vars.server.source_fmt.format(version=role.vars.server.version, arch=role.vars.arch)|yaml_dquote }}
    - source_hash: {{ role.vars.server.source_hash_fmt.format(version=role.vars.server.version, arch=role.vars.arch)|yaml_dquote }}
    - source_hash_update: True
    - enforce_toplevel: False
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - options: '--strip-components=1'
    - list_options: '--strip-components=1'
    - require:
      - file: prometheus/server/install

prometheus/server/config:
  file.managed:
    - name: {{ (_install_path ~ '/prometheus.yml')|yaml_dquote }}
    - source: {{ role.tpl_path('server.yml.j2')|yaml_dquote }}
    - check_cmd: {{ (_install_path ~ '/promtool check config ')|yaml_dquote }}
    - template: 'jinja'
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - archive: prometheus/server/install

prometheus/server/service:
  file.managed:
    - name: '/etc/systemd/system/prometheus.service'
    - source: {{ role.tpl_path('server.service.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        install_path: {{ _install_path|yaml_dquote }}
        vars: {{ role.vars|yaml }}
    - require:
      - archive: prometheus/server/install

  module.run:
    - name: 'service.systemctl_reload'
    - onchanges:
      - file: prometheus/server/service

  service.running:
    - name: 'prometheus.service'
    - enable: True
    - reload: True
    - require:
      - module: prometheus/server/service
    - watch:
      - file: prometheus/server/config

prometheus/server/service-restart:
  service.running:
    - name: 'prometheus.service'
    - watch:
      - archive: prometheus/server/install
      - file: prometheus/server/service
    - require:
      - service: prometheus/server/service
