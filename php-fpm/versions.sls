{% from slspath ~ '/init.sls' import role %}

{% for _version_name, _version in role.vars.versions|dictsort %}
{% set _version_state = 'php-fpm/version/' ~ _version_name %}
{% set _version = salt['ss.merge_recursive'](role.vars.version_defaults, _version) %}
{% set _version = salt['ss.format_recursive'](_version, version=_version_name) %}
{% set _version_configs = {
  'early': ['00-saltstack.ini', _version.base_config_dir ~ '/saltstack-early.ini'],
  'main': ['99-saltstack.ini', _version.base_config_dir ~ '/saltstack-main.ini'],
} %}

{{ _version_state }}/packages:
  pkg.installed:
    - pkgs: {{ _version.packages|yaml }}
    - require:
      - sls: php-fpm.global

{{ _version_state }}/pool-dir:
  file.directory:
    - name: {{ _version.fpm_pool_dir|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - clean: True
    - require:
      - pkg: {{ _version_state }}/packages

{% for _config_name, _config_paths in _version_configs|dictsort %}
{% set _config_data = _version.get(_config_name ~ '_config') %}

{{ _version_state }}/config/{{ _config_name }}:
  file.managed:
    - name: {{ _config_paths[1] }}
    - source: {{ role.tpl_path('php.ini.j2') }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        vars: {{ role.vars|yaml }}
        config: {{ _config_data|yaml }}
    - require:
      - pkg: {{ _version_state }}/packages
    - watch_in:
      - service: {{ _version_state }}/service

{{ _version_state }}/config/{{ _config_name }}/cli:
  file.symlink:
    - name: {{ (_version.cli_config_dir ~ '/' ~ _config_paths[0])|yaml_dquote }}
    - target: {{ _config_paths[1]|yaml_dquote }}
    - force: True
    - require:
      - file: {{ _version_state }}/config/{{ _config_name }}

{{ _version_state }}/config/{{ _config_name }}/fpm:
  file.symlink:
    - name: {{ (_version.fpm_config_dir ~ '/' ~ _config_paths[0])|yaml_dquote }}
    - target: {{ _config_paths[1]|yaml_dquote }}
    - force: True
    - require:
      - file: {{ _version_state }}/config/{{ _config_name }}
    - watch_in:
      - service: {{ _version_state }}/service

{% endfor %}

{% for _pool_name, _pool in _version.pools|dictsort %}
{% set _pool = salt['ss.merge_recursive'](role.vars.pool_defaults, _pool) %}
{% set _pool = salt['ss.merge_recursive']({
  'listen': _version.fpm_socket_prefix ~ _pool_name ~ '.sock',
}, _pool) %}

{{ _version_state }}/pool/{{ _pool_name }}:
  file.managed:
    - name: {{ (_version.fpm_pool_dir ~ '/' ~ _pool_name ~ '.conf')|yaml_dquote }}
    - source: {{ role.tpl_path('pool.conf.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - dir_mode: '0755'
    - makedirs: True
    - context:
        vars: {{ role.vars|yaml }}
        pool_name: {{ _pool_name|yaml }}
        pool_config: {{ _pool|yaml }}
    - require:
      - pkg: {{ _version_state }}/packages
    - require_in:
      - file: {{ _version_state }}/pool-dir
    - watch_in:
      - service: {{ _version_state }}/service
{% endfor %}

{{ _version_state }}/service:
  {% if _version.pools.keys()|length > 0 %}
  service.running:
    - name: {{ _version.service|yaml_dquote }}
    - enable: True
    - reload: True
  {% else %}
  service.dead:
    - name: {{ _version.service|yaml_dquote }}
    - enable: False
  {% endif %}

{% endfor %}
