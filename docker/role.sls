{% from slspath ~ '/init.sls' import role %}

include:
  - .dependencies

docker/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}
    - require:
      - custom: $system/repository/docker

docker/daemon-config:
  file.managed:
    - name: {{ role.daemon_config_path|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/daemon.json.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0640'
    - context:
        options: {{ role.daemon_options|yaml }}
    - require:
      - pkg: docker/packages

docker/service:
  service.running:
    - name: {{ role.service|yaml_dquote }}
    - enable: True
    - watch:
      - file: docker/daemon-config
