{% from slspath ~ '/init.sls' import role, software %}

{{ software.repository(
  state_id='docker/repository',
  name='docker',
  sources=role.vars.repository_sources,
  gpg_key_url=role.vars.repository_gpg_key_url
) }}

docker/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}
    - require:
      - docker/repository

docker/daemon-config:
  file.managed:
    - name: {{ role.vars.daemon_config_path|yaml_dquote }}
    - source: {{ role.tpl_path('daemon.json.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0640'
    - context:
        options: {{ role.vars.daemon_options|yaml }}
    - require:
      - pkg: docker/packages

docker/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: True
    - watch:
      - file: docker/daemon-config
