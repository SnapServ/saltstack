{% from 'nginx/init.sls' import role %}

{% macro virtualhost(name) %}
{% set _state_id = kwargs.get('state_id', 'nginx/vhost/{0}'.format(name)) %}
{% set _vhost = salt['ss.merge_recursive'](role.vars.vhost_defaults, _vhost) %}
{% set _vhost_dir = role.vars.vhost_data_dir ~ '/' ~ name %}

{% set _vhost_user = kwargs.get('app_user', none) or role.vars.service_user %}
{% set _vhost_group = kwargs.get('app_group', none) or role.vars.service_group %}

{{ _state_id }}/filesystem/vhost:
  file.directory:
    - name: {{ _vhost_dir|yaml_dquote }}
    - user: 'root'
    - group: 'www-data'
    - mode: '0750'
    - makedirs: True
    - require:
      - pkg: nginx/packages

{{ _state_id }}/filesystem/app:
  file.directory:
    - name: {{ (_vhost_dir ~ '/app')|yaml_dquote }}
    - user: {{ _vhost_user|yaml_dquote }}
    - group: {{ _vhost_group|yaml_dquote }}
    - mode: '2770'
    - require:
      - file: {{ _state_id }}/filesystem/vhost

{{ _state_id }}/filesystem/app/public:
  file.directory:
    - name: {{ (_vhost_dir ~ '/app/public')|yaml_dquote }}
    - user: {{ _vhost_user|yaml_dquote }}
    - group: {{ _vhost_group|yaml_dquote }}
    - mode: '2770'
    - require:
      - file: {{ _state_id }}/filesystem/app

{{ _state_id }}/filesystem/cfg:
  file.directory:
    - name: {{ (_vhost_dir ~ '/cfg')|yaml_dquote }}
    - user: 'root'
    - group: 'www-data'
    - mode: '0770'
    - require:
      - file: {{ _state_id }}/filesystem/vhost

{{ _state_id }}/filesystem/log:
  file.directory:
    - name: {{ (_vhost_dir ~ '/log')|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0750'
    - require:
      - file: {{ _state_id }}/filesystem/vhost 

{{ _state_id }}/filesystem/tmp:
  file.directory:
    - name: {{ (_vhost_dir ~ '/tmp')|yaml_dquote }}
    - user: {{ _vhost_user|yaml_dquote }}
    - group: 'root'
    - mode: '1770'
    - require:
      - file: {{ _state_id }}/filesystem/vhost

{{ _state_id }}/config:
  file.managed:
    - name: {{ (role.vars.vhosts_dir ~ '/' ~ name ~ '.conf')|yaml_dquote }}
    - source: 'salt://nginx/files/vhost.conf.j2'
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - dir_mode: '0755'
    - makedirs: True
    - context:
        vars: {{ role.vars|yaml }}
        vhost_name: {{ name|yaml }}
        vhost_config: {{ kwargs|yaml }}
        vhost_dir: {{ _vhost_dir|yaml }}
    - require:
      - file: {{ _state_id }}/filesystem/app/public
      - file: {{ _state_id }}/filesystem/cfg
      - file: {{ _state_id }}/filesystem/log
      - file: {{ _state_id }}/filesystem/tmp
    - require_in:
      - file: nginx/vhosts-dir
    - watch_in:
      - service: nginx/service-reload
{% endmacro %}
