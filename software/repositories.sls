{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import software %}
{%- from stdlib.formula_macros(tpldir) import software_repository %}

include:
  - .packages

software/repository-dir:
  file.directory:
    - name: {{ software.sources_dir|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - clean: {{ False if opts['arg'] else True }}

software/default-repository:
  file.managed:
    - name: {{ software.sources_path|yaml_dquote }}
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

{%- for _repo_name, _repo in software.repositories|dictsort %}
  {{- software_repository(_repo_name, **_repo) }}
{%- endfor %}
