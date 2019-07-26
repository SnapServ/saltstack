{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import nginx %}

{##############################################################################
 ## nginx_virtualhost
 ##############################################################################}
{%- macro nginx_virtualhost(name) %}

{#- Merge vhost settings with defaults #}
{%- set _vhost = salt['defaults.merge'](
  nginx.vhost_defaults, kwargs, in_place=False
) %}

{#- Build state ID prefix and determine virtual host settings #}
{%- set _vhost_sid = 'nginx/vhost/' ~ name %}
{%- set _vhost_dir = nginx.vhost_data_dir ~ '/' ~ name %}
{%- set _vhost_user = _vhost.app_user or nginx.service_user %}
{%- set _vhost_group = _vhost.app_group or nginx.service_group %}

{{ _vhost_sid }}/filesystem/vhost:
  file.directory:
    - name: {{ _vhost_dir|yaml_dquote }}
    - user: 'root'
    - group: 'www-data'
    - mode: '0750'
    - makedirs: True
    - require:
      - pkg: nginx/packages

{{ _vhost_sid }}/filesystem/app:
  file.directory:
    - name: {{ (_vhost_dir ~ '/app')|yaml_dquote }}
    - user: {{ _vhost_user|yaml_dquote }}
    - group: {{ _vhost_group|yaml_dquote }}
    - mode: '2770'
    - require:
      - file: {{ _vhost_sid }}/filesystem/vhost

{{ _vhost_sid }}/filesystem/app/public:
  file.directory:
    - name: {{ (_vhost_dir ~ '/app/public')|yaml_dquote }}
    - user: {{ _vhost_user|yaml_dquote }}
    - group: {{ _vhost_group|yaml_dquote }}
    - mode: '2770'
    - require:
      - file: {{ _vhost_sid }}/filesystem/app

{{ _vhost_sid }}/filesystem/cfg:
  file.directory:
    - name: {{ (_vhost_dir ~ '/cfg')|yaml_dquote }}
    - user: 'root'
    - group: 'www-data'
    - mode: '0770'
    - require:
      - file: {{ _vhost_sid }}/filesystem/vhost

{{ _vhost_sid }}/filesystem/log:
  file.directory:
    - name: {{ (_vhost_dir ~ '/log')|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0750'
    - require:
      - file: {{ _vhost_sid }}/filesystem/vhost 

{{ _vhost_sid }}/filesystem/tmp:
  file.directory:
    - name: {{ (_vhost_dir ~ '/tmp')|yaml_dquote }}
    - user: {{ _vhost_user|yaml_dquote }}
    - group: 'root'
    - mode: '1770'
    - require:
      - file: {{ _vhost_sid }}/filesystem/vhost

{{ _vhost_sid }}/config:
  file.managed:
    - name: {{ (nginx.vhosts_dir ~ '/' ~ name ~ '.conf')|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['vhost.conf.j2'],
        lookup='vhost-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - dir_mode: '0755'
    - makedirs: True
    - context:
        nginx: {{ nginx|yaml }}
        vhost_name: {{ name|yaml }}
        vhost_config: {{ _vhost|yaml }}
        vhost_dir: {{ _vhost_dir|yaml }}
    - require:
      - file: {{ _vhost_sid }}/filesystem/app/public
      - file: {{ _vhost_sid }}/filesystem/cfg
      - file: {{ _vhost_sid }}/filesystem/log
      - file: {{ _vhost_sid }}/filesystem/tmp
    - require_in:
      - file: nginx/vhosts-dir
    - watch_in:
      - service: nginx/service-reload

{%- endmacro %}
