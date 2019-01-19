{% from slspath ~ '/init.sls' import role %}
{% import slspath ~ '/macros.sls' as software %}

software/repository/dir:
  file.directory:
    - name: {{ role.sources_dir|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - clean: True

software/repository/default:
  file.managed:
    - name: {{ role.sources_path|yaml_dquote }}
    - contents: '# Managed by SaltStack in /etc/apt/sources.list.d'
    - user: 'root'
    - group: 'root'
    - mode: '0444'
    - require:
        - pkg: software/dependencies
        - pkg: software/packages/removed
        - pkg: software/packages/purged
    - require_in:
        - pkg: software/packages/installed
        - pkg: software/packages/latest

{% for _repo_name, _repo in role.repositories|dictsort %}
  {{- software.declare_repository(_repo_name, _repo) -}}
{% endfor %}
