{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import php_fpm %}

{% for _version_name, _version in php_fpm.versions|dictsort %}

{#- Merge user settings with default settings, then apply format strings #}
{%- set _version = salt['defaults.merge'](
  php_fpm.version_defaults, _version, in_place=False
) %}
{% set _version = salt['ss.format_recursive'](_version, version=_version_name) %}

{#- Build state ID and determine version settings #}
{% set _version_sid = 'php-fpm/version/' ~ _version_name %}
{% set _version_configs = {
  'early': ['00-saltstack.ini', _version.base_config_dir ~ '/saltstack-early.ini'],
  'main': ['99-saltstack.ini', _version.base_config_dir ~ '/saltstack-main.ini'],
} %}

{{ _version_sid }}/packages:
  pkg.installed:
    - pkgs: {{ _version.packages|yaml }}
    - require:
      - sls: php-fpm.global

{{ _version_sid }}/pool-dir:
  file.directory:
    - name: {{ _version.fpm_pool_dir|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - clean: True
    - require:
      - pkg: {{ _version_sid }}/packages

{%- for _config_name, _config_paths in _version_configs|dictsort %}
{%- set _config_data = _version.get(_config_name ~ '_config') %}

{{ _version_sid }}/config/{{ _config_name }}:
  file.managed:
    - name: {{ _config_paths[1] }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['php.ini.j2'],
        lookup='php-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        vars: {{ php_fpm|yaml }}
        config: {{ _config_data|yaml }}
    - require:
      - pkg: {{ _version_sid }}/packages
    - watch_in:
      - service: {{ _version_sid }}/service

{{ _version_sid }}/config/{{ _config_name }}/cli:
  file.symlink:
    - name: {{ (_version.cli_config_dir ~ '/' ~ _config_paths[0])|yaml_dquote }}
    - target: {{ _config_paths[1]|yaml_dquote }}
    - force: True
    - require:
      - file: {{ _version_sid }}/config/{{ _config_name }}

{{ _version_sid }}/config/{{ _config_name }}/fpm:
  file.symlink:
    - name: {{ (_version.fpm_config_dir ~ '/' ~ _config_paths[0])|yaml_dquote }}
    - target: {{ _config_paths[1]|yaml_dquote }}
    - force: True
    - require:
      - file: {{ _version_sid }}/config/{{ _config_name }}
    - watch_in:
      - service: {{ _version_sid }}/service

{%- endfor %}

{%- for _pool_name, _pool in _version.pools|dictsort %}

{#- Merge pool settings with defaults #}
{%- set _pool = salt['defaults.merge'](
  php_fpm.pool_defaults,
  _pool,
  in_place=False
) %}

{#- Build path to listen socket if missing #}
{%- set _pool = salt['defaults.merge']({
  'listen': _version.fpm_socket_prefix ~ _pool_name ~ '.sock',
}, _pool, in_place=False) %}

{#- Declare pool #}
{{ _version_sid }}/pool/{{ _pool_name }}:
  file.managed:
    - name: {{ (_version.fpm_pool_dir ~ '/' ~ _pool_name ~ '.conf')|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['pool.conf.j2'],
        lookup='fpm-pool-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - dir_mode: '0755'
    - makedirs: True
    - context:
        vars: {{ php_fpm|yaml }}
        pool_name: {{ _pool_name|yaml }}
        pool_config: {{ _pool|yaml }}
    - require:
      - pkg: {{ _version_sid }}/packages
    - require_in:
      - file: {{ _version_sid }}/pool-dir
    - watch_in:
      - service: {{ _version_sid }}/service

{%- endfor %}

{{ _version_sid }}/service:
  {%- if _version.pools.keys()|length > 0 %}
  service.running:
    - name: {{ _version.service|yaml_dquote }}
    - enable: True
    - reload: True
  {%- else %}
  service.dead:
    - name: {{ _version.service|yaml_dquote }}
    - enable: False
  {%- endif %}

{%- endfor %}
