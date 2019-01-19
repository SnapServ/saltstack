{% set role = salt['custom.role_data']('software') %}

{% macro repository_macro(_name, _options) %}
{% set _repo_file = role.sources_dir ~ '/' ~ role.sources_name_tpl.format(_name) %}

$system/repository/{{ _name }}:
  custom.resource: []

software/repository/{{ _name }}:
  pkgrepo.managed:
    - names: {{ _options.sources|default([])|yaml }}
    - comments: ['Managed by SaltStack']
{% if _options.gpg_key_url is defined %}
    - key_url: {{ _options.gpg_key_url|yaml_dquote }}
{% elif _options.gpg_key_server is defined and _options.gpg_key_id is defined %}
    - keyserver: {{ _options.gpg_key_server|yaml_dquote }}
    - keyid: {{ _options.gpg_key_id|yaml_dquote }}
{% endif %}
    - file: {{ _repo_file|yaml_dquote }}
    - onchanges_in:
      - custom: $system/repository/{{ _name }}
    - require:
      - file: software/repository/default
    - require_in:
      - pkg: software/packages/installed
      - pkg: software/packages/latest

  file.exists:
    - name: {{ _repo_file|yaml_dquote }}
    - require:
      - pkgrepo: software/repository/{{ _name }}
    - require_in:
      - file: software/repository/dir

{% endmacro %}
