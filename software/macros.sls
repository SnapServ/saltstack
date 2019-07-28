{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import software %}

{##############################################################################
 ## software_repository
 ##############################################################################}
{%- macro software_repository(name, sources) %}
{%- call stdlib.formula_resource_block(tpldir, 'software-repository', name) %}

{#- Generate state ID and path to repository file #}
{%- set _repo_sid = 'software/repository/' ~ name %}
{%- set _repo_file = software.sources_dir ~ '/'
      ~ software.sources_name_tpl.format(name) %}

{#- Apply format strings in repository sources #}
{%- set _sources = [] %}
{%- for _source in sources %}
  {%- do _sources.append(_source.format(**grains)) %}
{%- endfor %}

{#- Declare software repository, use file.exists to avoid cleaning #}
{{ _repo_sid|yaml_dquote }}:
  pkgrepo.managed:
    - names: {{ _sources|yaml }}
    - comments: ['Managed by SaltStack']
    {%- if kwargs.gpg_key_url is defined %}
    - key_url: {{ kwargs.get('gpg_key_url', none)|yaml_dquote }}
    {%- elif kwargs.gpg_key_server is defined and kwargs.gpg_key_id is defined %}
    - keyserver: {{ kwargs.get('gpg_key_server', none)|yaml_dquote }}
    - keyid: {{ kwargs.get('gpg_key_id', none)|yaml_dquote }}
    {%- endif %}
    - file: {{ _repo_file|yaml_dquote }}
    - onchanges_in:
      - {{ stdlib.resource_dep('software-repository', name) }}
    - require:
      - file: software/default-repository
    - require_in:
      - pkg: software/packages/installed
      - pkg: software/packages/latest

  file.exists:
    - name: {{ _repo_file|yaml_dquote }}
    - onchanges_in:
      - {{ stdlib.resource_dep('software-repository', name) }}
    - require:
      - pkgrepo: {{ _repo_sid|yaml_dquote }}
    - require_in:
      - file: software/repository-dir

{%- endcall %}
{% endmacro %}
