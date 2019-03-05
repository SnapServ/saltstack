{% set role = salt['ss.role']('software') %}

{% macro repository(name, sources) %}
{% set _state_id = kwargs.get('state_id', 'software/repository/{0}'.format(name)) %}
{% set _repo_file = role.vars.sources_dir ~ '/' ~ role.vars.sources_name_tpl.format(name) %}

{{ role.resource('repository', name) }}:
  ss.resource: []

{{ _state_id }}:
  pkgrepo.managed:
    - names: {{ sources|yaml }}
    - comments: ['Managed by SaltStack']
    {% if kwargs.gpg_key_url is defined %}
    - key_url: {{ kwargs.get('gpg_key_url', none)|yaml_encode }}
    {% elif kwargs.gpg_key_server is defined and kwargs.gpg_key_id is defined %}
    - keyserver: {{ kwargs.get('gpg_key_server', none)|yaml_encode }}
    - keyid: {{ kwargs.get('gpg_key_id', none)|yaml_encode }}
    {% endif %}
    - file: {{ _repo_file|yaml_dquote }}
    - onchanges_in:
      - {{ role.resource('repository', name) }}
    - require:
      - file: software/repository/default
    - require_in:
      - pkg: software/packages/installed
      - pkg: software/packages/latest

  file.exists:
    - name: {{ _repo_file|yaml_dquote }}
    - onchanges_in:
      - {{ role.resource('repository', name) }}
    - require:
      - pkgrepo: {{ _state_id }}
    - require_in:
      - file: software/repository-dir
{% endmacro %}
