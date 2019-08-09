{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import software %}

{##############################################################################
 ## software_repository
 ##############################################################################}
{%- macro software_repository(name, sources, gpg_key_url=none,
                              gpg_key_server=none, gpg_key_id=none) %}
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
    {%- if gpg_key_url %}
    - key_url: {{ gpg_key_url|yaml_dquote }}
    {%- elif gpg_key_server and gpg_key_id %}
    - keyserver: {{ gpg_key_server|yaml_dquote }}
    - keyid: {{ gpg_key_id|yaml_dquote }}
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
