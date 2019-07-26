{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import docker %}
{%- from stdlib.formula_macros('software') import software_repository %}

include:
  - software

{{ software_repository(
  name='docker',
  sources=docker.repository_sources,
  gpg_key_url=docker.repository_gpg_key_url
) }}

docker/packages:
  pkg.installed:
    - pkgs: {{ docker.packages|yaml }}
    - require:
      - {{ stdlib.resource_dep('software-repository', 'docker') }}

docker/daemon-config:
  file.managed:
    - name: {{ docker.daemon_config_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['daemon.json.j2'],
        lookup='daemon-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0640'
    - context:
        docker: {{ docker|yaml }}
    - require:
      - pkg: docker/packages

docker/service:
  service.running:
    - name: {{ docker.service|yaml_dquote }}
    - enable: True
    - watch:
      - file: docker/daemon-config
